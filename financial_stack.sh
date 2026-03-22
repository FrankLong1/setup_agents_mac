#!/usr/bin/env bash
set -e

# Helper functions
install_formula() {
    local formula=$1
    if brew list --formula | grep -q "^${formula}\$"; then
        echo "✓ ${formula} already installed"
        brew upgrade ${formula} 2>/dev/null || true
    else
        echo "Installing ${formula}..."
        brew install ${formula}
    fi
}

install_cask() {
    local cask=$1
    if brew list --cask | grep -q "^${cask}\$"; then
        echo "✓ ${cask} already installed"
    else
        echo "Installing ${cask}..."
        brew install --cask ${cask} 2>/dev/null || echo "⚠️  Could not install ${cask}"
    fi
}

install_npm_global() {
    local package=$1
    if npm list -g ${package} &>/dev/null; then
        echo "✓ ${package} already installed"
    else
        echo "Installing ${package}..."
        npm install -g ${package}
    fi
}

setup_homebrew_path() {
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# Main script
echo "💰 Financial Stack Development Environment Setup"
echo "=================================================="
echo ""

# Check macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS only"
    exit 1
fi

# Xcode Command Line Tools
echo "📦 Checking Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏳ Please complete the installation, then re-run this script"
    exit 0
else
    echo "✅ Xcode Command Line Tools already installed"
fi

# Homebrew
echo ""
echo "📦 Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    setup_homebrew_path
else
    echo "✅ Homebrew already installed"
fi

# System dependencies
echo ""
echo "📦 Installing system dependencies..."
for formula in python3 node git uv ripgrep; do
    install_formula ${formula}
done

# Core AI Tools
echo ""
echo "📦 Installing Core AI Tools..."
for cask in cursor voiceink; do
    install_cask ${cask}
done

# Puppeteer MCP Server
echo ""
echo "📦 Installing Puppeteer MCP Server..."
install_npm_global @modelcontextprotocol/server-puppeteer

echo ""
echo "🎉 Financial Stack setup complete!"
