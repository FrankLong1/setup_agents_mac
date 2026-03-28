# Mac Environment Setup

Ansible-based setup that reproduces a full Mac dev environment from scratch. One config file, one command.

## Quick Start

```bash
cd ansible && ./run.sh
```

## What It Does

Installs and configures:

- **CLI tools** — git, node, python, uv, ripgrep, docker, tmux, awscli, go, etc.
- **Desktop apps** — Cursor, VS Code, Chrome, Obsidian, Spotify, Zoom, Signal, Claude, etc.
- **AI tools** — Claude Code, Gemini CLI, Goose, ccusage, Puppeteer MCP
- **VS Code extensions** — Copilot, Python, Jupyter, Go, Docker, Terraform, etc.
- **Dotfiles** — .gitconfig, .tmux.conf, .zshrc, Claude settings
- **macOS preferences** — Dock, Finder, keyboard repeat settings
- **Go tools** — delve, gopls, golangci-lint, staticcheck

## Configuration

Each role owns its config in `roles/<name>/defaults/main.yml`. Override any default in `group_vars/all.yml`.

- To add a package: append it to the relevant list
- To remove a package: delete the line

## Run Individual Pieces

```bash
./run.sh prerequisites  # Xcode, Homebrew, helpers
./run.sh homebrew       # CLI tools + desktop apps
./run.sh dotfiles       # Config files
./run.sh vscode         # VS Code extensions
./run.sh macos          # System preferences
./run.sh backup         # Back up current machine (BEFORE wiping!)
```

## Backup Before Wiping

```bash
cd ansible && ./run.sh backup
```

Backs up: Brewfile, App Store list, VS Code extensions, npm globals, SSH keys, fonts.

See [SETUP_PLAN.md](SETUP_PLAN.md) for the full pre-wipe checklist and manual steps.
