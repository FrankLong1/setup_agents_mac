#!/usr/bin/env bash
# Installs a per-user LaunchAgent. It makes no network or credential changes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCTOR_SCRIPT="${SCRIPT_DIR}/mount-doctor.sh"
LABEL="com.frank.nas-mount-doctor"
AGENT_PATH="${HOME}/Library/LaunchAgents/${LABEL}.plist"

[[ "$(uname -s)" == "Darwin" ]] || { echo "This installer supports macOS only." >&2; exit 2; }
[[ -x "${DOCTOR_SCRIPT}" ]] || { echo "Run: chmod +x ${DOCTOR_SCRIPT}" >&2; exit 2; }
[[ -r "${HOME}/.config/nas-mount-doctor.env" || -r "${SCRIPT_DIR}/mount-doctor.local.env" ]] || {
  echo "Create ~/.config/nas-mount-doctor.env or nas/mount-doctor.local.env from nas/mount-doctor.env.example first." >&2
  exit 2
}

mkdir -p "${HOME}/Library/LaunchAgents"
cat >"${AGENT_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>${LABEL}</string>
  <key>ProgramArguments</key><array><string>${DOCTOR_SCRIPT}</string></array>
  <key>RunAtLoad</key><true/>
  <key>StartInterval</key><integer>300</integer>
  <key>StandardOutPath</key><string>${HOME}/Library/Logs/nas-mount-doctor.log</string>
  <key>StandardErrorPath</key><string>${HOME}/Library/Logs/nas-mount-doctor.log</string>
</dict></plist>
EOF

launchctl bootout "gui/$(id -u)" "${AGENT_PATH}" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "${AGENT_PATH}"
launchctl kickstart -k "gui/$(id -u)/${LABEL}"
echo "Installed ${LABEL}; it will check at login and every five minutes."
