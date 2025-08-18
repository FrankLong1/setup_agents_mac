#!/usr/bin/env bash
set -e

echo "🚀 SlideAgent Mac Setup Script"
echo "================================"
echo "This script will install all dependencies needed for SlideAgent development"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS only"
    exit 1
fi

echo "📦 Checking Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools (this may take a while)..."
    xcode-select --install
    echo "⏳ Please complete the Xcode CLT installation in the popup window, then re-run this script"
    exit 0
else
    echo "✅ Xcode Command Line Tools already installed"
fi

echo ""
echo "📦 Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew already installed"
fi

echo ""
echo "📦 Installing system dependencies via Homebrew..."
# Install or upgrade formulae, skip if already up-to-date
for formula in python3 node git uv ripgrep; do
    if brew list --formula | grep -q "^${formula}\$"; then
        echo "✓ ${formula} already installed, checking for updates..."
        brew upgrade ${formula} 2>/dev/null || echo "  ${formula} is up-to-date"
    else
        echo "Installing ${formula}..."
        brew install ${formula}
    fi
done

echo ""
echo "📦 Installing development tools..."
# Install casks, skip if already installed
for cask in cursor voiceink warp visual-studio-code obsidian; do
    if brew list --cask | grep -q "^${cask}\$"; then
        echo "✓ ${cask} already installed"
    else
        # Check if app already exists in /Applications
        app_name=""
        case ${cask} in
            cursor) app_name="Cursor.app" ;;
            voiceink) app_name="VoiceInk.app" ;;
            warp) app_name="Warp.app" ;;
            visual-studio-code) app_name="Visual Studio Code.app" ;;
            obsidian) app_name="Obsidian.app" ;;
        esac
        
        if [[ -n "${app_name}" ]] && [[ -d "/Applications/${app_name}" ]]; then
            echo "✓ ${cask} app already exists in /Applications"
        else
            echo "Installing ${cask}..."
            brew install --cask ${cask} 2>/dev/null || echo "⚠️  Could not install ${cask}"
        fi
    fi
done

echo ""
echo "📦 Installing Claude Code CLI..."
if npm list -g @anthropic-ai/claude-code &>/dev/null; then
    echo "✓ Claude Code CLI already installed"
else
    npm install -g @anthropic-ai/claude-code
fi

echo ""
echo "📦 Installing ccusage (Claude Code usage analyzer)..."
if npm list -g ccusage &>/dev/null; then
    echo "✓ ccusage already installed"
else
    npm install -g ccusage
fi

echo ""
echo "📦 Installing Goose CLI..."
if brew list --formula | grep -q "^block-goose-cli\$"; then
    echo "✓ Goose CLI already installed"
else
    brew install block-goose-cli
fi

echo ""
echo "📦 Installing Vercel CLI for web deployment..."
if npm list -g vercel &>/dev/null; then
    echo "✓ Vercel CLI already installed"
else
    npm install -g vercel
fi

echo ""
echo "📦 Installing Puppeteer MCP server globally..."
if npm list -g @modelcontextprotocol/server-puppeteer &>/dev/null; then
    echo "✓ Puppeteer MCP server already installed"
else
    npm install -g @modelcontextprotocol/server-puppeteer
fi

echo ""
echo "🔧 Configuring Claude Code with Puppeteer MCP..."
# Give Claude Code a moment to be available in PATH
sleep 2
if command -v claude &> /dev/null; then
    claude mcp add puppeteer 2>/dev/null || echo "⚠️  Puppeteer MCP may already be configured or require manual setup"
else
    echo "⚠️  Claude CLI not found - please run 'claude mcp add puppeteer' manually after installation"
fi

echo ""
echo "🎉 System setup complete!"
echo ""
echo "================================"
echo "Next steps for SlideAgent setup:"
echo "1. cd into your SlideAgent directory"
echo "2. Run: uv sync (installs Python deps, creates .venv automatically)"
echo "3. Run: npm install (installs Node.js deps)"
echo ""
echo "Note: With uv, use 'uv run' prefix for Python commands (no venv activation needed)"
echo ""
echo "Happy presenting! 🎨"