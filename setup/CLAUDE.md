# Setup

Run from the repository root:

```bash
./setup.sh --profile personal
```

Useful variants:

```bash
./setup.sh --profile personal --check
./setup.sh --profile personal --tag homebrew
./setup.sh --profile personal --tag dotfiles
./setup.sh --profile personal --tag macos
./verify.sh --profile personal
```

`profiles/<name>.Brewfile` declares installed software. `profiles/<name>.yml` declares preferences, personal identity, required commands and apps, and manual steps. `group_vars/all.yml` contains cross-profile defaults only.

Legacy restore experiments remain outside the active playbook; the golden-workstation flow manages installed software and configuration only.
