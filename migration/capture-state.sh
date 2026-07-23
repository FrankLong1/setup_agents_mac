#!/usr/bin/env bash
set -euo pipefail

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_dir="${1:-${HOME}/mac-setup-inventory/${timestamp}}"

mkdir -p "${output_dir}"

echo "Capturing installed-state inventory in ${output_dir}"

{
  sw_vers
  uname -m
  printf 'captured_at_utc=%s\n' "${timestamp}"
} > "${output_dir}/system.txt"

if command -v brew >/dev/null 2>&1; then
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle dump \
    --file="${output_dir}/Brewfile" \
    --force
else
  echo "Homebrew is not installed" > "${output_dir}/Brewfile.unavailable"
fi

find /Applications "${HOME}/Applications" \
  -maxdepth 1 -type d -name '*.app' -exec basename {} \; 2>/dev/null \
  | sort -u > "${output_dir}/applications.txt"

if [[ -d "${HOME}/Library/Fonts" ]]; then
  find "${HOME}/Library/Fonts" -maxdepth 1 -type f -exec basename {} \; \
    | sort > "${output_dir}/fonts.txt"
else
  : > "${output_dir}/fonts.txt"
fi

if command -v code >/dev/null 2>&1; then
  code --list-extensions | sort > "${output_dir}/vscode-extensions.txt"
fi

if command -v cursor >/dev/null 2>&1; then
  cursor --list-extensions | sort > "${output_dir}/cursor-extensions.txt"
fi

if command -v npm >/dev/null 2>&1; then
  npm list -g --depth=0 --json > "${output_dir}/npm-globals.json" 2>/dev/null || true
fi

echo "Capture complete. This inventory contains no SSH keys, tokens, or user documents."
echo "Compare ${output_dir}/Brewfile with setup/profiles/personal.Brewfile before promoting changes."
