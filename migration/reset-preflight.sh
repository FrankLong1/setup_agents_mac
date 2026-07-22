#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MAX_DEPTH=2
OUTPUT_FILE=""
SCAN_ROOTS=()
blockers=0
warnings=0

usage() {
  cat <<'EOF'
Usage: ./migration/reset-preflight.sh [options]

Read-only checks for obvious factory-reset data-loss risks. This script never
starts a backup, changes an account, uploads data, or erases the Mac.

Options:
  --scan-root PATH  Scan PATH for Git work at risk (repeatable; default: ~/Projects)
  --max-depth N     Limit Git discovery depth (default: 2; add nested roots explicitly)
  --output FILE     Also save the non-secret Markdown report to FILE
  -h, --help        Show this help
EOF
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scan-root)
      [[ $# -ge 2 ]] || die "--scan-root requires a path"
      SCAN_ROOTS+=("$2")
      shift 2
      ;;
    --max-depth)
      [[ $# -ge 2 ]] || die "--max-depth requires a number"
      [[ "$2" =~ ^[1-9][0-9]*$ ]] || die "--max-depth must be a positive integer"
      MAX_DEPTH="$2"
      shift 2
      ;;
    --output)
      [[ $# -ge 2 ]] || die "--output requires a path"
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

if [[ ${#SCAN_ROOTS[@]} -eq 0 ]]; then
  SCAN_ROOTS=("${HOME}/Projects")
fi

REPORT_TMP="$(mktemp "${TMPDIR:-/tmp}/mac-reset-preflight.XXXXXX")"
trap 'rm -f "${REPORT_TMP}"' EXIT

emit() {
  printf '%s\n' "$*" >> "${REPORT_TMP}"
}

pass() {
  emit "- PASS: $*"
}

warn() {
  warnings=$((warnings + 1))
  emit "- WARNING: $*"
}

block() {
  blockers=$((blockers + 1))
  emit "- BLOCKER: $*"
}

display_path() {
  local path="$1"
  if [[ "$path" == "${HOME}"* ]]; then
    printf '~%s' "${path#${HOME}}"
  else
    printf '%s' "$path"
  fi
}

emit "# Mac reset preflight"
emit ""
emit "Generated at UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
emit ""
emit "This report contains status and paths, never credentials or file contents."
emit ""
emit "## Machine checks"

if [[ "$(uname -s 2>/dev/null || true)" != "Darwin" ]]; then
  block "The preflight must run on the Mac that would be erased."
else
  product_version="$(sw_vers -productVersion 2>/dev/null || printf unknown)"
  architecture="$(uname -m 2>/dev/null || printf unknown)"
  pass "macOS ${product_version} on ${architecture}."
fi

if command -v fdesetup >/dev/null 2>&1; then
  if fdesetup status 2>/dev/null | grep -q 'FileVault is On'; then
    pass "FileVault is on."
  else
    warn "FileVault is not reported as on; protect any external backup with encryption."
  fi
else
  warn "FileVault status could not be checked."
fi

if ! command -v tmutil >/dev/null 2>&1; then
  block "Time Machine tooling is unavailable."
else
  time_machine_running=false
  if tmutil status 2>/dev/null | grep -q 'Running = 1'; then
    time_machine_running=true
    block "A Time Machine backup is still running; wait for completion and rerun."
  fi
  if [[ "${time_machine_running}" == false ]]; then
    latest_backup_output="$(tmutil latestbackup 2>&1)"
    latest_backup_status=$?
    if [[ ${latest_backup_status} -eq 0 && -n "${latest_backup_output}" ]]; then
      pass "An accessible Time Machine backup exists ($(basename "${latest_backup_output}"))."
      emit "- MANUAL: Confirm the Time Machine menu shows a backup from today and restore one test file before erasing."
    elif printf '%s' "${latest_backup_output}" | grep -qi 'Full Disk Access'; then
      block "The latest Time Machine backup cannot be verified without Full Disk Access. Verify today's completion in the Time Machine menu and perform a test restore."
    else
      block "No accessible completed Time Machine backup was found. Attach the backup disk, run Back Up Now, and rerun."
    fi
  fi
fi

emit ""
emit "## Important local data"
for important_path in \
  "${HOME}/Desktop" \
  "${HOME}/Documents" \
  "${HOME}/Downloads" \
  "${HOME}/Projects" \
  "${HOME}/Library/Mobile Documents/com~apple~CloudDocs"; do
  if [[ -e "${important_path}" ]]; then
    size="$(du -sh "${important_path}" 2>/dev/null | awk '{print $1}' || true)"
    emit "- $(display_path "${important_path}"): ${size:-size unavailable}"
  else
    emit "- $(display_path "${important_path}"): not present"
  fi
done
emit "- MANUAL: In Finder, show the iCloud Status column and resolve every Waiting to Upload, Out of Space, or Ineligible item."
emit "- MANUAL: Verify representative critical files from iCloud.com or a second trusted device. iCloud sync is not a substitute for a versioned backup."

emit ""
emit "## Git work at risk"
repo_count=0
risky_repo_count=0
emit ""
emit "| Repository | Branch | Tracked changes | Untracked work | Ahead of upstream | Upstream |"
emit "| --- | --- | --- | --- | ---: | --- |"

while IFS= read -r git_marker; do
  [[ -n "${git_marker}" ]] || continue
  repo="${git_marker%/.git}"
  repo_count=$((repo_count + 1))
  branch="$(git -C "${repo}" branch --show-current 2>/dev/null || true)"
  [[ -n "${branch}" ]] || branch="detached"
  tracked_changes=no
  untracked_work=no
  if ! git -C "${repo}" diff-index --quiet HEAD -- 2>/dev/null; then
    tracked_changes=yes
  fi
  if [[ -n "$(git -C "${repo}" ls-files --others --exclude-standard --directory --no-empty-directory 2>/dev/null | sed -n '1p')" ]]; then
    untracked_work=yes
  fi
  upstream="$(git -C "${repo}" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true)"
  ahead_count=0
  upstream_status="configured"
  if [[ -n "${upstream}" ]]; then
    ahead_count="$(git -C "${repo}" rev-list --count "${upstream}..HEAD" 2>/dev/null || printf unknown)"
  else
    upstream_status="missing"
  fi

  repo_risky=false
  if [[ "${tracked_changes}" == yes || "${untracked_work}" == yes ]]; then
    repo_risky=true
  fi
  if [[ "${ahead_count}" != 0 ]]; then
    repo_risky=true
  fi
  if [[ "${upstream_status}" == missing ]]; then
    repo_risky=true
  fi

  if [[ "${repo_risky}" == true ]]; then
    risky_repo_count=$((risky_repo_count + 1))
    emit "| \`$(display_path "${repo}")\` | \`${branch}\` | ${tracked_changes} | ${untracked_work} | ${ahead_count} | ${upstream_status} |"
  fi
done < <(
  for scan_root in "${SCAN_ROOTS[@]}"; do
    if [[ -d "${scan_root}" ]]; then
      find "${scan_root}" -maxdepth "${MAX_DEPTH}" -name .git -print 2>/dev/null
    fi
  done | sort -u
)

if [[ ${repo_count} -eq 0 ]]; then
  warn "No Git repositories were discovered under the selected scan roots."
elif [[ ${risky_repo_count} -gt 0 ]]; then
  block "${risky_repo_count} of ${repo_count} discovered Git repositories have uncommitted work, unpushed commits, or no configured upstream."
else
  pass "All ${repo_count} discovered Git repositories are clean and have no locally-ahead commits."
fi
emit "- NOTE: Remote-tracking refs are not fetched by this read-only check. Confirm important branches on GitHub from another device."
emit "- NOTE: The default depth covers repositories directly under each scan root. Pass additional --scan-root paths for nested worktree collections that matter."

emit ""
emit "## Bootstrap access"
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  pass "GitHub CLI is authenticated on this Mac."
else
  warn "GitHub CLI authentication is not currently healthy."
fi

if git -C "${REPO_DIR}" ls-remote --exit-code origin HEAD >/dev/null 2>&1; then
  pass "The setup repository is readable from its origin remote."
else
  block "The setup repository origin cannot be read; prove a clean clone from another device before erasing."
fi

emit ""
emit "## Manual account-recovery gates"
emit ""
emit "Do not put recovery codes, passwords, keys, or phone numbers in this report or repository."
emit ""
emit "- [ ] Apple Account password works from another device, and a trusted device or trusted phone number receives a verification code."
emit "- [ ] Passwords & Keychain is synced to another trusted Apple device, or the password-manager vault and emergency kit are independently recoverable."
emit "- [ ] Primary email, GitHub, Google, OpenAI, cloud-provider, and password-manager accounts each have two independent sign-in/recovery methods."
emit "- [ ] Fresh recovery codes are stored somewhere that will survive this Mac, with an offline copy for the highest-value accounts."
emit "- [ ] Device-bound passkeys or security keys exist on at least two separate devices/keys."
emit "- [ ] A private-window sign-in fire drill succeeded for Apple Account, primary email, GitHub, and the password manager."
emit "- [ ] A second independent backup exists, and one representative file was restored from it."

emit ""
emit "## Result"
emit ""
if [[ ${blockers} -gt 0 ]]; then
  emit "NO-GO: ${blockers} automated blocker(s), ${warnings} warning(s), plus the unchecked manual gates above. Do not erase this Mac."
  result=1
else
  emit "AUTOMATED CHECKS PASS: ${warnings} warning(s). This is not erase approval until every manual gate above is proved."
  result=0
fi

cat "${REPORT_TMP}"
if [[ -n "${OUTPUT_FILE}" ]]; then
  output_parent="$(dirname "${OUTPUT_FILE}")"
  [[ -d "${output_parent}" ]] || die "output directory does not exist: ${output_parent}"
  cp "${REPORT_TMP}" "${OUTPUT_FILE}"
  printf 'Saved report to %s\n' "${OUTPUT_FILE}" >&2
fi

exit "${result}"
