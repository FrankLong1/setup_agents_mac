# Mac Golden Workstation

Reproduce a lean, supportable Mac baseline with one command.

```bash
./setup.sh --profile personal
```

The `personal` profile is the clean-rebuild baseline. Homebrew Bundle owns installed software; Ansible owns dotfiles, editor settings, macOS preferences, Dock layout, optional App Store apps, and verification. The historical everything-list is retained as an explicit `--full` option so a factory reset does not immediately recreate years of accumulated software.

## What is reproduced

- Homebrew formulae, casks, taps, and services
- VS Code extensions, Go tools, and global npm tools recorded by Homebrew Bundle
- Selected Mac App Store apps
- Git, tmux, zsh, Claude Code, Cursor, and VS Code configuration
- Selected Dock, Finder, and keyboard preferences
- A verification report and a concise manual-login checklist

User documents, credentials, browser sessions, and application data are deliberately outside the scope of this repository. Before erasing a Mac, use the [factory-reset runbook](FACTORY_RESET_RUNBOOK.md) and its read-only preflight. See [MANUAL_APPS.md](MANUAL_APPS.md) for direct-download apps and the interactive login checklist.

## Commands

```bash
./setup.sh --profile personal             # apply the complete personal setup
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
setup.sh                         one-command entry point
setup/profiles/personal.Brewfile lean clean-rebuild package baseline
setup/profiles/personal-full.Brewfile historical installed-software receipt
setup/profiles/personal.yml      personal preferences and verification contract
setup/roles/                     idempotent configuration areas
setup/verify.yml                 read-only verification playbook
setup/restore.yml                explicit opt-in, config-only legacy restore
migration/capture-state.sh       safe installed-state inventory
migration/reset-preflight.sh     read-only erase-readiness checks
FACTORY_RESET_RUNBOOK.md         backup, 2FA, erase, and selective-restore gate
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
