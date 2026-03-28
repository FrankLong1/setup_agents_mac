#!/usr/bin/env bash
set -e

BACKUP_DIR="${1:-$HOME/mac_backup}"

echo "=================================================="
echo "  Capture Current Machine State"
echo "=================================================="
echo ""
echo "Backup directory: $BACKUP_DIR"
echo ""

mkdir -p "$BACKUP_DIR"

# Homebrew packages
echo "Dumping Brewfile..."
brew bundle dump --file="$BACKUP_DIR/Brewfile" --force

# Mac App Store apps
echo "Listing App Store apps..."
mas list > "$BACKUP_DIR/mas_apps.txt" 2>/dev/null || echo "(mas not available or not signed in)"

# VS Code extensions
echo "Listing VS Code extensions..."
code --list-extensions > "$BACKUP_DIR/vscode_extensions.txt" 2>/dev/null || echo "(VS Code not available)"

# Global npm packages
echo "Listing global npm packages..."
npm list -g --depth=0 > "$BACKUP_DIR/npm_globals.txt" 2>/dev/null || echo "(npm not available)"

# SSH keys
if [ -d "$HOME/.ssh" ]; then
    echo "Backing up SSH keys..."
    rsync -a "$HOME/.ssh/" "$BACKUP_DIR/ssh_keys/"
fi

# Fonts
if [ -d "$HOME/Library/Fonts" ]; then
    echo "Backing up fonts..."
    rsync -a "$HOME/Library/Fonts/" "$BACKUP_DIR/fonts/"
fi

# Raycast
if [ -d "$HOME/Library/Application Support/com.raycast.macos" ]; then
    echo "Backing up Raycast config..."
    rsync -a "$HOME/Library/Application Support/com.raycast.macos/" "$BACKUP_DIR/raycast/"
fi

# Editor settings (Cursor + VS Code share the same config, just back up one)
if [ -d "$HOME/Library/Application Support/Cursor/User" ]; then
    echo "Backing up editor settings (from Cursor)..."
    rsync -a "$HOME/Library/Application Support/Cursor/User/" "$BACKUP_DIR/editor_settings/"
fi

# Obsidian config
OBSIDIAN_VAULT="$HOME/Documents/Obsidian"
if [ -d "$OBSIDIAN_VAULT/.obsidian" ]; then
    echo "Backing up Obsidian config..."
    rsync -a "$OBSIDIAN_VAULT/.obsidian/" "$BACKUP_DIR/obsidian_config/"
fi

# GitHub CLI config
if [ -d "$HOME/.config/gh" ]; then
    echo "Backing up GitHub CLI config..."
    rsync -a "$HOME/.config/gh/" "$BACKUP_DIR/gh_cli/"
fi

# API key variable names (redacted values)
echo "Capturing environment variable names..."
grep -r "API_KEY\|SECRET\|TOKEN\|ANTHROPIC\|OPENAI" \
    "$HOME/.zshrc" \
    "$HOME/.bashrc" \
    "$HOME/.bash_profile" \
    "$HOME/.zprofile" 2>/dev/null \
| sed 's/=.*/=<REDACTED>/' > "$BACKUP_DIR/env_var_names.txt" || true

echo ""
echo "=================================================="
echo "  BACKUP COMPLETE"
echo "=================================================="
echo ""
echo "Location: $BACKUP_DIR"
echo ""
echo "Contents:"
for item in "$BACKUP_DIR"/*; do
    echo "  $(basename "$item")"
done
echo ""
echo "NEXT: Copy $BACKUP_DIR to external drive or cloud storage."
echo "DO NOT store unencrypted SSH keys in cloud — use an encrypted archive."
