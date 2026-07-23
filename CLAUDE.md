# Mac Golden Workstation

This repository defines a reproducible personal Mac software and configuration profile with a future fleet-management seam.

## Apply

```bash
./setup.sh --profile personal
```

## Preview and verify

```bash
./setup.sh --profile personal --check
./verify.sh --profile personal
```

Homebrew Bundle owns software installation. Ansible owns dotfiles, editor settings, macOS preferences, Dock layout, optional App Store apps, and verification. Profiles live in `setup/profiles/`.

The repository never stores SSH private keys, tokens, browser sessions, user documents, or application databases.
