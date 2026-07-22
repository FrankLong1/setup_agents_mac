from __future__ import annotations

import os
import shutil
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def run(*args: str, cwd: Path = ROOT, env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        cwd=cwd,
        env=env,
        text=True,
        capture_output=True,
        check=False,
    )


def write_executable(path: Path, body: str) -> None:
    path.write_text(body, encoding="utf-8")
    path.chmod(path.stat().st_mode | stat.S_IXUSR)


class RepositoryContractTests(unittest.TestCase):
    def test_shell_entrypoints_parse(self) -> None:
        scripts = [
            "setup.sh",
            "verify.sh",
            "setup/run.sh",
            "migration/capture-state.sh",
            "migration/reset-preflight.sh",
        ]
        for script in scripts:
            with self.subTest(script=script):
                result = run("bash", "-n", script)
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_default_profile_is_lean_and_full_profile_is_explicit(self) -> None:
        lean = (ROOT / "setup/profiles/personal.Brewfile").read_text(encoding="utf-8")
        full = (ROOT / "setup/profiles/personal-full.Brewfile").read_text(encoding="utf-8")
        run_script = (ROOT / "setup/run.sh").read_text(encoding="utf-8")

        lean_entries = [line for line in lean.splitlines() if line and not line.startswith("#")]
        full_entries = [line for line in full.splitlines() if line and not line.startswith("#")]
        self.assertLess(len(lean_entries), 60)
        self.assertGreater(len(full_entries), len(lean_entries) + 80)
        self.assertNotIn('brew "postgresql@16"', lean)
        self.assertNotIn('cask "steam"', lean)
        self.assertNotIn('cask "codex-app"', lean + full)
        self.assertIn("--full", run_script)
        self.assertIn('${PROFILE}-full.Brewfile', run_script)

    def test_clean_profile_does_not_recreate_permission_bypasses(self) -> None:
        profile = (ROOT / "setup/profiles/personal.yml").read_text(encoding="utf-8")
        self.assertNotIn("dangerously-skip-permissions", profile)
        self.assertNotIn("gemini --yolo", profile)
        self.assertIn("skip_dangerous_mode_prompt: false", profile)
        self.assertIn("remote_control_at_startup: false", profile)

    def test_legacy_restore_excludes_credentials(self) -> None:
        restore = (ROOT / "setup/roles/restore/tasks/main.yml").read_text(encoding="utf-8")
        self.assertIn("allow_legacy_config_restore", restore)
        self.assertNotIn("gh_cli", restore)
        self.assertNotIn("ssh_keys", restore)
        self.assertNotIn("failed_when: false", restore)

    def test_recovery_runbook_pins_a_published_commit(self) -> None:
        runbook = (ROOT / "FACTORY_RESET_RUNBOOK.md").read_text(encoding="utf-8")
        self.assertIn("exact reviewed commit SHA", runbook)
        self.assertIn("git checkout <REVIEWED_RECOVERY_COMMIT_SHA>", runbook)
        self.assertIn("a local-only branch is not a", runbook)

    def _preflight_environment(self, home: Path, *, backup_exists: bool) -> dict[str, str]:
        bin_dir = home / "mock-bin"
        projects = home / "Projects"
        bin_dir.mkdir()
        projects.mkdir()

        write_executable(
            bin_dir / "uname",
            "#!/bin/bash\ncase \"${1:-}\" in -s) echo Darwin ;; -m) echo arm64 ;; *) echo Darwin ;; esac\n",
        )
        write_executable(
            bin_dir / "sw_vers",
            "#!/bin/bash\nif [[ \"${1:-}\" == -productVersion ]]; then echo 26.5.2; else echo macOS; fi\n",
        )
        write_executable(bin_dir / "fdesetup", "#!/bin/bash\necho 'FileVault is On.'\n")
        tmutil_latest = "echo /Volumes/Backup/2026-07-21-120000.backup" if backup_exists else "exit 1"
        write_executable(
            bin_dir / "tmutil",
            "#!/bin/bash\ncase \"${1:-}\" in status) echo 'Running = 0' ;; latestbackup) "
            + tmutil_latest
            + " ;; *) exit 1 ;; esac\n",
        )
        write_executable(bin_dir / "gh", "#!/bin/bash\nexit 0\n")
        write_executable(bin_dir / "git", "#!/bin/bash\nexit 0\n")

        env = os.environ.copy()
        env["HOME"] = str(home)
        env["PATH"] = f"{bin_dir}:{env['PATH']}"
        return env

    def test_preflight_passes_automated_checks_with_backup(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            env = self._preflight_environment(home, backup_exists=True)
            result = run(
                "bash",
                "migration/reset-preflight.sh",
                "--scan-root",
                str(home / "Projects"),
                env=env,
            )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("AUTOMATED CHECKS PASS", result.stdout)
        self.assertIn("manual account-recovery gates", result.stdout.lower())

    def test_preflight_blocks_without_time_machine_backup(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            env = self._preflight_environment(home, backup_exists=False)
            result = run(
                "bash",
                "migration/reset-preflight.sh",
                "--scan-root",
                str(home / "Projects"),
                env=env,
            )
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("No accessible completed Time Machine backup", result.stdout)
        self.assertIn("NO-GO", result.stdout)

    @unittest.skipUnless(shutil.which("ansible-playbook"), "ansible-playbook is not installed")
    def test_ansible_playbooks_parse(self) -> None:
        for playbook in ("site.yml", "verify.yml", "restore.yml"):
            with self.subTest(playbook=playbook):
                result = run(
                    "ansible-playbook",
                    playbook,
                    "--syntax-check",
                    "--extra-vars",
                    "mac_profile=personal",
                    cwd=ROOT / "setup",
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
