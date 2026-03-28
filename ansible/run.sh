#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=================================================="
echo "  Mac Environment Setup (Ansible)"
echo "=================================================="
echo ""
echo "Config: ansible/group_vars/all.yml"
echo ""

# Check ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "Installing Ansible via Homebrew..."
    brew install ansible
fi

# Install required Ansible collections
echo "Ensuring required Ansible collections are installed..."
ansible-galaxy collection install community.general --force-with-deps 2>/dev/null || true

# Usage
usage() {
    echo "Usage: ./run.sh [TAG]"
    echo ""
    echo "Tags:"
    echo "  prerequisites  — Xcode, Homebrew, helper tools, Brewfile snapshot"
    echo "  homebrew       — CLI tools + desktop apps (casks)"
    echo "  mas            — Mac App Store apps (Magnet, Kindle, etc.)"
    echo "  dotfiles       — .gitconfig, .tmux.conf, .zshrc, Claude settings, MCP servers"
    echo "  vscode         — VS Code extensions"
    echo "  npm            — Global npm packages"
    echo "  go             — Go tools (delve, gopls, golangci-lint, etc.)"
    echo "  macos          — System preferences (Dock, Finder, keyboard)"
    echo "  backup         — Back up current machine state (run BEFORE wiping!)"
    echo ""
    echo "Examples:"
    echo "  ./run.sh              # Full setup (excludes backup)"
    echo "  ./run.sh homebrew     # Just apps & CLI tools"
    echo "  ./run.sh backup       # Backup current machine"
    exit 0
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
fi

# Allow running specific tags
if [ -n "$1" ]; then
    echo "Running with tags: $1"
    ansible-playbook site.yml --tags "$1" -v
else
    echo "Running full setup..."
    ansible-playbook site.yml -v
fi

echo ""
echo "Done! See post-install manual steps above."
