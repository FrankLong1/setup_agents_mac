#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_URL="https://github.com/FrankLong1/setup_agents_mac.git"
TARGET_DIR="${SETUP_AGENTS_MAC_DIR:-${HOME}/Projects/setup_agents_mac}"

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  echo "Finish installing Xcode Command Line Tools, then rerun this script."
  exit 2
fi

if [[ -e "${TARGET_DIR}" ]]; then
  echo "Refusing to overwrite existing path: ${TARGET_DIR}" >&2
  echo "Run ${TARGET_DIR}/setup.sh directly, or choose SETUP_AGENTS_MAC_DIR for a new destination." >&2
  exit 1
fi

mkdir -p "$(dirname "${TARGET_DIR}")"
git clone "${REPOSITORY_URL}" "${TARGET_DIR}"
exec "${TARGET_DIR}/setup.sh" --profile personal "$@"
