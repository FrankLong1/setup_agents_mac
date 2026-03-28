# Mac Environment Reproduction Plan

## Quick Start

```bash
# 1. BEFORE wiping — back up current machine
cd ansible && ./run.sh backup

# 2. ON NEW MACHINE — full setup
cd ansible && ./run.sh
```

## Architecture

```
ansible/
├── site.yml                    # Main playbook — orchestrates all roles
├── group_vars/all.yml          # THE config file — everything listed is installed
├── run.sh                      # Entry point (installs Ansible if needed)
├── ansible.cfg
├── inventory.yml
└── roles/
    ├── prerequisites/          # Xcode, Homebrew, mas, brew bundle snapshot
    ├── homebrew/               # CLI tools (formulae) + desktop apps (casks)
    ├── mas_apps/               # Mac App Store apps (Magnet, Kindle, etc.)
    ├── dotfiles/               # .gitconfig, .tmux.conf, .zshrc, Claude settings, MCP servers
    ├── vscode/                 # VS Code extensions
    ├── npm_globals/            # Global npm packages
    ├── go_tools/               # Go tools (delve, gopls, golangci-lint, etc.)
    ├── macos_defaults/         # System preferences (Dock, Finder, keyboard)
    └── backup/                 # Back up current machine state
```

## Run individual pieces

```bash
./run.sh prerequisites  # Xcode, Homebrew, helpers, Brewfile snapshot
./run.sh homebrew       # CLI tools + desktop apps
./run.sh mas            # Mac App Store apps
./run.sh dotfiles       # Config files + MCP servers
./run.sh vscode         # VS Code extensions
./run.sh npm            # Global npm packages
./run.sh go             # Go tools
./run.sh macos          # System preferences
./run.sh backup         # Back up current machine (run BEFORE wiping!)
```

## How to customize

Edit `ansible/group_vars/all.yml` — everything listed will be installed.

To add a package: append it to the relevant list.
To remove a package: delete the line.

---

## Essential Prerequisites

These must exist before Ansible can take over:

1. **Xcode Command Line Tools** — `xcode-select --install` (handled by prerequisites role)
2. **Homebrew** — the package manager for macOS (handled by prerequisites role)
3. **Python 3** — comes with Homebrew, needed for Ansible
4. **Ansible** — `brew install ansible` (handled by `run.sh`)

### System Access Requirements

- **Full Disk Access** — Grant your Terminal app in System Settings > Privacy & Security. Without this, Ansible can't back up ~/.ssh or sensitive configs.

---

## What Requires Manual Steps

### 1. Authentication & Logins (unavoidable)

| Service | Command / Action |
|---------|-----------------|
| GitHub | `gh auth login` |
| Google Cloud | `gcloud auth login` |
| AWS | `aws configure` (need access key + secret) |
| Claude | `claude login` |
| Vercel | `vercel login` |
| Docker Hub | `docker login` |
| Chrome | Sign in to sync bookmarks/extensions |
| Spotify, Signal, WhatsApp, Zoom | Sign in to each app |

### 2. SSH Keys

**Before wiping old machine:**
```bash
./run.sh backup   # backs up ~/.ssh automatically
```
**On new machine:**
```bash
cp -r ~/mac_backup/ssh_keys ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### 3. Non-Homebrew Apps (install manually)

| App | Source |
|-----|--------|
| We Love Lights | manual download |
| FastestVPN | App Store or website |

### 4. API Keys & Environment Variables

Store actual values in a password manager. Add to `~/.zshrc.secrets` (sourced by .zshrc).

---

## Noah's Ark Checklist (before wiping)

Run `./run.sh backup` first, then verify:

- [ ] All git repos pushed (`find ~ -name .git -type d`)
- [ ] SSH keys backed up
- [ ] API keys / env vars stored in password manager
- [ ] Obsidian vault synced
- [ ] Browser bookmarks synced (Chrome sync)
- [ ] ~/Documents, ~/Desktop backed up if needed
- [ ] Backup directory copied to external drive / cloud

---

## Testing

Test on a clean macOS VM before running on your main machine:

```bash
# Using UTM or Parallels with a macOS VM
cd ansible && ./run.sh
```
