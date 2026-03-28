# Migration — Capture Current Machine State

Run this BEFORE wiping the old machine. Zero dependencies beyond Homebrew (which is already installed if you have things to back up).

## Usage

```bash
cd migration && ./capture-state.sh
```

Optionally specify a custom backup directory:

```bash
./capture-state.sh /Volumes/ExternalDrive/mac_backup
```

## What It Captures

| Item | Output |
|------|--------|
| Homebrew packages + casks | `Brewfile` |
| Mac App Store apps | `mas_apps.txt` |
| VS Code extensions | `vscode_extensions.txt` |
| Global npm packages | `npm_globals.txt` |
| SSH keys | `ssh_keys/` |
| Custom fonts | `fonts/` |
| Raycast config | `raycast/` |
| Editor settings (Cursor/VS Code) | `editor_settings/` |
| Obsidian config | `obsidian_config/` |
| GitHub CLI config | `gh_cli/` |
| Env var names (redacted) | `env_var_names.txt` |

`Brewfile.snapshot` in this directory is a reference snapshot from a previous system — useful for diffing against `setup/group_vars/all.yml` to check for missing packages.

## Pre-Wipe Checklist

Run `./capture-state.sh` first, then verify:

- [ ] All git repos pushed (`find ~ -name .git -type d`)
- [ ] SSH keys backed up
- [ ] API keys / env vars stored in password manager
- [ ] Obsidian vault synced
- [ ] Browser bookmarks synced (Chrome sync)
- [ ] ~/Documents, ~/Desktop backed up if needed
- [ ] Backup directory copied to external drive / cloud

## Restoring SSH Keys on New Machine

```bash
cp -r ~/mac_backup/ssh_keys ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

## API Keys & Environment Variables

Store actual values in a password manager. On the new machine, add them to `~/.zshrc.secrets` (sourced by .zshrc, not tracked in git).
