#!/usr/bin/env bash
# Keep an existing Finder/SMB connection available after Wi-Fi or the NAS wakes.
# Configuration: ~/.config/nas-mount-doctor.env (copy the example first).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${HOME}/.config/nas-mount-doctor.env"
LOCAL_CONFIG_FILE="${SCRIPT_DIR}/mount-doctor.local.env"

log() {
  printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

if [[ -r "${CONFIG_FILE}" ]]; then
  active_config="${CONFIG_FILE}"
elif [[ -r "${LOCAL_CONFIG_FILE}" ]]; then
  active_config="${LOCAL_CONFIG_FILE}"
else
  log "No configuration at ${CONFIG_FILE} or ${LOCAL_CONFIG_FILE}; nothing to do."
  exit 0
fi

# shellcheck source=/dev/null
source "${active_config}"

if declare -p NAS_DATA_URLS >/dev/null 2>&1; then
  data_urls=("${NAS_DATA_URLS[@]}")
elif [[ -n "${NAS_DATA_URL:-}" ]]; then
  # Compatibility with the single-share format used by earlier versions.
  data_urls=("${NAS_DATA_URL}")
else
  log "No NAS data-share URLs are configured; nothing to do."
  exit 0
fi

for data_url in "${data_urls[@]}"; do
  if [[ "${data_url}" != smb://* ]]; then
    log "Skipping invalid SMB URL: ${data_url}"
    continue
  fi

  share_name="${data_url#smb://}"
  share_name="${share_name#*/}"
  share_name="${share_name%%/*}"
  mount_path="/Volumes/${share_name}"

  if mount | grep -Fq " on ${mount_path} (smbfs,"; then
    log "Data share is mounted at ${mount_path}."
  else
    # Finder uses the saved Keychain credential. On the first manual connection,
    # select "Remember this password"; launchd must never receive a password.
    open -g "${data_url}"
    log "Asked Finder to connect ${data_url}."
  fi
done

if [[ -n "${NAS_TIME_MACHINE_URL:-}" ]]; then
  if tmutil destinationinfo 2>/dev/null | grep -Fq "${NAS_TIME_MACHINE_URL}"; then
    log "Time Machine destination is configured for the NAS."
  else
    log "Time Machine destination is not confirmed; check System Settings > General > Time Machine."
  fi
fi
