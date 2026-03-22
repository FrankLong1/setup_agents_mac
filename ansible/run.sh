#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=================================================="
echo "  Mac Environment Setup (Ansible)"
echo "=================================================="
echo ""
echo "Review what will be installed:"
echo "  -> ansible/group_vars/all.yml"
echo ""
echo "Uncomment/comment items, set enabled: true/false"
echo ""

# Check ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "Installing Ansible via Homebrew..."
    brew install ansible
fi

# Install required Ansible collections
echo "Ensuring required Ansible collections are installed..."
ansible-galaxy collection install community.general --force-with-deps 2>/dev/null || true

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
