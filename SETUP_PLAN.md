# Mac Environment Reproduction Plan

## What's Automated (Ansible handles this)

```bash
cd ansible && ./run.sh
```

Or run individual pieces:
```bash
./run.sh homebrew    # Just apps & CLI tools
./run.sh dotfiles    # Just config files
./run.sh vscode      # Just VS Code extensions
./run.sh npm         # Just global npm packages
./run.sh macos       # Just system preferences
./run.sh ai_tools    # Just AI tool configs
```

### How to review before running
Edit `ansible/group_vars/all.yml` — everything is categorized and togglable.
Commented-out items = stuff currently on your machine that I flagged as "probably don't need on next machine."
Enabled items = recommended to keep.

---

## What Requires Manual Steps

### 1. Authentication & Logins (unavoidable)
These store credentials in Keychain / browser sessions — can't be automated:

| Service | Command / Action |
|---------|-----------------|
| GitHub | `gh auth login` |
| Google Cloud | `gcloud auth login` |
| AWS | `aws configure` (need access key + secret) |
| Claude | `claude login` |
| Vercel | `vercel login` |
| npm registry | `npm login` (if publishing) |
| Docker Hub | `docker login` |
| App Store apps | Sign in to App Store manually |
| Chrome | Sign in to sync bookmarks/extensions |
| Spotify | Sign in to app |
| Signal/WhatsApp | QR code scan from phone |
| Zoom | Sign in to app |
| Obsidian Sync | Sign in if using Obsidian Sync |
| Google Drive | Sign in to desktop app |

### 2. SSH Keys
**Before wiping old machine:**
```bash
# Back up SSH keys
cp -r ~/.ssh /path/to/backup/ssh_keys
```
**On new machine:**
```bash
cp -r /path/to/backup/ssh_keys ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### 3. Obsidian Vault
Your notes/vault needs to be synced via:
- Obsidian Sync (paid), OR
- Git repo, OR
- iCloud/Google Drive folder

### 4. Warp Launch Configurations
Your `~/.warp/launch_configurations/` has custom tmux session configs.
These are tracked in a separate repo — just clone it on the new machine.

### 5. Non-Homebrew Apps (install manually)
These are on your current machine but not installable via `brew`:
- ChatGPT Atlas (download from openai.com)
- Amazon Kindle (App Store)
- Caffeine (App Store or download)
- Magnet (App Store)
- Raycast (download from raycast.com)
- Wispr Flow (download from wispr.com)
- WeChat (App Store)
- Logitech Options+ (download from logitech.com)
- balenaEtcher (download from balena.io)
- duet (download from duetdisplay.com)

### 6. API Keys & Environment Variables
**Before wiping old machine**, export these:
```bash
# Check for any API keys in shell configs
grep -r "API_KEY\|SECRET\|TOKEN" ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile ~/.zprofile
```
Store them in a password manager, then add them to `~/.zshrc` on the new machine.

### 7. Fonts
If you've installed custom fonts:
```bash
# Back up fonts
cp -r ~/Library/Fonts /path/to/backup/fonts
```

---

## Speculative / Nice-to-Have Automations

### Could add later:
1. **Raycast settings export/import** — Raycast has a built-in export feature
2. **macOS Keyboard shortcuts** — can be set via `defaults write` but fragile across OS versions
3. **Dock app ordering** — possible via `defaults write com.apple.dock persistent-apps` but finicky
4. **Finder sidebar favorites** — possible but hacky
5. **App Store apps via `mas`** — `brew install mas` then `mas install <app-id>` for Magnet, Kindle, etc.
6. **1Password / Bitwarden CLI** for secrets — could inject API keys from password manager during setup
7. **Warp config backup role** — clone the launch_configurations repo automatically

---

## Noah's Ark Checklist (before wiping)

- [ ] Push all git repos (see repo-finder output)
- [ ] Back up ~/.ssh
- [ ] Back up API keys / env vars from .zshrc
- [ ] Back up Obsidian vault
- [ ] Back up any local databases (PostgreSQL data)
- [ ] Export Raycast settings
- [ ] Export browser bookmarks (if not using Chrome sync)
- [ ] Back up ~/Documents, ~/Desktop if needed
- [ ] Back up custom fonts
- [ ] Screenshot your Dock layout and app positions
- [ ] Note down any App Store purchases to re-download
