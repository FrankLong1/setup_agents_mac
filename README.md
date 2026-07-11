# Mac Golden Workstation

Reproduce the useful software and configuration from the reference Mac with one command.

```bash
./setup.sh --profile personal
```

The `personal` profile is the current golden-workstation definition. Homebrew Bundle owns installed software; Ansible owns dotfiles, editor settings, macOS preferences, Dock layout, optional App Store apps, and verification.

## What is reproduced

- Homebrew formulae, casks, taps, and services
- VS Code extensions, Go tools, and global npm tools recorded by Homebrew Bundle
- Selected Mac App Store apps
- Git, tmux, zsh, Claude Code, Cursor, and VS Code configuration
- Selected Dock, Finder, and keyboard preferences
- A verification report and a concise manual-login checklist

User documents, credentials, browser sessions, and application data are deliberately outside the scope of this repository.

## Commands

```bash
./setup.sh --profile personal             # apply the complete personal setup
./setup.sh --profile personal --check     # preview configuration changes
./setup.sh --profile personal --tag macos # apply one Ansible area
./verify.sh --profile personal            # verify without changing the Mac
./migration/capture-state.sh              # capture a fresh installed-state inventory
```

The first run may stop and ask you to finish the Xcode Command Line Tools installer. Rerun the same command afterward. Homebrew, Ansible, and the required Ansible collection are bootstrapped automatically.

## Layout

```text
setup.sh                         one-command entry point
setup/profiles/personal.Brewfile complete installed-software receipt
setup/profiles/personal.yml      personal preferences and verification contract
setup/roles/                     idempotent configuration areas
setup/verify.yml                 read-only verification playbook
migration/capture-state.sh       safe installed-state inventory
```

## Future fleet use

The profile boundary is intentional. A future MDM bootstrap can run the same entry point with a non-personal profile:

```bash
./setup.sh --profile developer
```

MDM should eventually own enrollment, security policy, certificates, FileVault, privacy profiles, and OS updates. This repository should continue to own workstation software and developer configuration. No MDM vendor is required for the personal phase.

## Manual steps

Some services still require interactive sign-in, including GitHub, cloud providers, browsers, messaging apps, and licensed software. The setup prints the profile-specific checklist at the end.
