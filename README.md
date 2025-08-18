# Mac Setup for AI Agents

A one-click setup script that installs everything you need to work with AI coding assistants on your Mac.

## Required Accounts (Create These First)

Before running the setup, you'll need these accounts:

1. **Claude Pro** ($20/month) - [Subscribe here](https://claude.ai/subscribe)
   - Required for Claude Code to work
   - Includes Claude Code desktop app access

2. **Vercel** (Free tier) - [Sign up here](https://vercel.com/signup)
   - For deploying websites instantly
   - Free tier includes unlimited personal projects

3. **GitHub** (Free) - [Sign up here](https://github.com/signup)
   - For saving and sharing your code
   - Required for many development workflows

4. **OpenAI** (Optional, pay-as-you-go) - [Sign up here](https://platform.openai.com/signup)
   - If you want to use GPT models alongside Claude
   - Only charged for what you use

## Quick Start

First, make the script executable (only needed once):
```bash
chmod +x setup_mac.sh
```

Then run the setup:
```bash
./setup_mac.sh
```

## What Gets Installed

### 🤖 AI Assistants
- **Claude Code** - Talk to Claude in your terminal to write and edit code
- **Goose** - Another AI assistant that helps with coding tasks
- **Puppeteer MCP** - Lets Claude control web browsers for you

### 📊 Monitoring Tools
- **ccusage** - See how much you're spending on Claude (tracks token usage and costs)

### 🌐 Web Deployment
- **Vercel** - Deploy websites instantly with one command (free for personal use)

### 💻 Code Editors & Terminals
- **Cursor** - Code editor with AI built-in (like VS Code but smarter)
- **VS Code** - Popular code editor from Microsoft
- **Warp** - Modern terminal that's easier to use than the default one
- **VoiceInk** - Dictate code and comments instead of typing
- **Obsidian** - Knowledge management and note-taking app

### 🔧 Behind-the-Scenes Tools
- **Homebrew** - Mac's app installer (like an app store for developer tools)
- **Python** - Programming language many tools need
- **Node.js & npm** - JavaScript runner and package manager
- **Git** - Saves versions of your files and syncs with GitHub
- **uv** - Fast Python package manager
- **ripgrep** - Lightning-fast file search tool

## Most Useful Commands

### Check Claude Costs
```bash
# See today's Claude usage and costs
ccusage

# Watch live usage while Claude is working
ccusage blocks --live

# This week's costs
ccusage daily --since $(date -v-7d +%Y%m%d)

# This month's total
ccusage monthly --since $(date +%Y%m01)
```

### Start AI Assistants
```bash
# Start Claude in current folder
claude

# Start Goose
goose
```

### Deploy Websites
```bash
# Deploy current folder to the web (first time)
vercel

# Deploy to production
vercel --prod

# Link to existing Vercel project
vercel link

# View your deployment
vercel open
```

### Quick Tips

**ccusage** - Run this daily to track your AI spending. Most people spend $5-20/month.

**Claude Code** - Your main assistant. Just type `claude` and describe what you want to build.

**Vercel** - Type `vercel` in any website folder to deploy it live instantly. Great for sharing projects!

**Cursor** - Open this instead of VS Code. It has AI built into every feature.

**Warp** - Use this instead of Terminal. It makes command-line work much easier.

## For SlideAgent Users

After running the setup script:

1. Navigate to your SlideAgent folder
2. Run `uv sync` to install Python dependencies
3. Run `npm install` to install JavaScript dependencies
4. You're ready to go!

## Troubleshooting

If something doesn't work, try running the setup script again - it's safe to run multiple times.

For help with specific tools:
- Claude Code: Type `claude --help`
- ccusage: Type `ccusage --help`
- Goose: Type `goose --help`
- Vercel: Type `vercel --help`