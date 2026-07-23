# Clean Mac regeneration plan

> **Status: M1 executable prototype, not a proven recovery product.**
>
> The architecture and desired-state boundaries are the durable work. The
> current Ansible and Brewfile implementation has passed static checks and
> macOS check mode, but it has not yet passed a clean-machine installation
> rehearsal. Read [ARCHITECTURE.md](ARCHITECTURE.md) before treating any command
> here as a reset procedure.

Target outcome: reproduce a lean, supportable Mac baseline from reviewable
manifests and selective restore paths.

```bash
./setup.sh --profile personal
```

The current `personal` profile is a prototype clean-rebuild baseline pending
human curation and a disposable clean-Mac rehearsal. Homebrew Bundle declares
installed software; Ansible currently manages dotfiles, editor settings, macOS
preferences, Dock layout, optional App Store apps, and verification. The
executor is replaceable. The historical everything-list is retained as an
explicit `--full` option so it cannot be mistaken for the target workstation.

## What the current prototype models

- Homebrew formulae, casks, taps, and services
- VS Code extensions, Go tools, and global npm tools recorded by Homebrew Bundle
- Selected Mac App Store apps
- Git, tmux, zsh, Claude Code, Cursor, and VS Code configuration
- Selected Dock, Finder, and keyboard preferences
- A verification report and a concise manual-login checklist

User documents, credentials, browser sessions, and application data are deliberately outside the scope of this repository. Before erasing a Mac, use the [factory-reset runbook](FACTORY_RESET_RUNBOOK.md) and its read-only preflight. See [MANUAL_APPS.md](MANUAL_APPS.md) for direct-download apps and the interactive login checklist.

The lean Brewfile is an intentionally curated baseline, not a dump of every
installed package. Follow [BREWFILE_GUIDE.md](BREWFILE_GUIDE.md) to capture
current state, decide what deserves to survive future resets, validate changes,
and remove accumulated packages safely.

## Prototype commands

These commands describe and exercise the current implementation. Do not run the
apply path on a primary Mac merely because CI passes.

```bash
./setup.sh --profile personal             # apply the current prototype profile
./setup.sh --profile personal --full      # opt in to the historical everything-list
./setup.sh --profile personal --check     # preview configuration changes
./setup.sh --profile personal --tag macos # apply one Ansible area
./verify.sh --profile personal            # verify without changing the Mac
./migration/capture-state.sh              # capture a fresh installed-state inventory
./migration/reset-preflight.sh            # report backup, Git, and recovery blockers
```

The first run may stop and ask you to finish the Xcode Command Line Tools installer. Rerun the same command afterward. Homebrew, Ansible, and the required Ansible collection are bootstrapped automatically.

The Homebrew `codex` cask supplies the Codex command-line tool. Install or update the Codex desktop app through its supported OpenAI distribution rather than the retired `codex-app` cask.

## Layout

```text
setup.sh                         prototype executor entry point
setup/profiles/personal.Brewfile lean clean-rebuild package baseline
setup/profiles/personal-full.Brewfile historical installed-software receipt
setup/profiles/personal.yml      personal preferences and verification contract
setup/roles/                     idempotent configuration areas
setup/verify.yml                 read-only verification playbook
setup/restore.yml                explicit opt-in, config-only legacy restore
migration/capture-state.sh       safe installed-state inventory
migration/reset-preflight.sh     read-only erase-readiness checks
FACTORY_RESET_RUNBOOK.md         backup, 2FA, erase, and selective-restore gate
ARCHITECTURE.md                  target model, trust boundaries, maturity gates
BREWFILE_GUIDE.md                package admission, curation, and cleanup policy
tests/                           local and CI regression contracts
```

## Future fleet use

The profile boundary is intentional. A future MDM bootstrap can run the same entry point with a non-personal profile:

```bash
./setup.sh --profile developer
```

MDM should eventually own enrollment, security policy, certificates, FileVault, privacy profiles, and OS updates. This repository should continue to own workstation software and developer configuration. No MDM vendor is required for the personal phase.

## Manual steps

Some services still require interactive sign-in, including GitHub, cloud providers, browsers, messaging apps, and licensed software. The setup prints the profile-specific checklist at the end. It never restores authentication databases, private keys, recovery codes, or browser sessions.

## Tests

```bash
python3 -m unittest discover -s tests -v
```

The same contract suite runs in GitHub Actions. It checks shell parsing,
Ansible syntax, the lean/full profile boundary, permission-bypass exclusions,
credential-safe restore behavior, and both pass/fail reset-preflight paths.
