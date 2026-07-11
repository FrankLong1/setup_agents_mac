#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

PROFILE="personal"
TAG=""
CHECK_MODE=false
VERIFY_ONLY=false

usage() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Options:
  --profile NAME   Apply setup/profiles/NAME.yml and NAME.Brewfile (default: personal)
  --tag TAG        Run one area: prerequisites, homebrew, mas, dotfiles, or macos
  --check          Preview Ansible-managed changes; do not install prerequisites or packages
  --verify         Verify the selected profile without changing the machine
  -h, --help       Show this help

A positional tag remains supported for compatibility, for example: ./setup/run.sh macos
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      [[ $# -ge 2 ]] || die "--profile requires a value"
      PROFILE="$2"
      shift 2
      ;;
    --tag)
      [[ $# -ge 2 ]] || die "--tag requires a value"
      TAG="$2"
      shift 2
      ;;
    --check)
      CHECK_MODE=true
      shift
      ;;
    --verify)
      VERIFY_ONLY=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -* )
      die "unknown option: $1"
      ;;
    *)
      [[ -z "${TAG}" ]] || die "only one positional tag is supported"
      TAG="$1"
      shift
      ;;
  esac
done

[[ "${PROFILE}" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || die "invalid profile name: ${PROFILE}"
[[ -f "profiles/${PROFILE}.yml" ]] || die "missing profile: setup/profiles/${PROFILE}.yml"
[[ -f "profiles/${PROFILE}.Brewfile" ]] || die "missing Brewfile: setup/profiles/${PROFILE}.Brewfile"
[[ "$(uname -s)" == "Darwin" ]] || die "this setup currently supports macOS only"

if ! xcode-select -p >/dev/null 2>&1; then
  if [[ "${CHECK_MODE}" == true || "${VERIFY_ONLY}" == true ]]; then
    die "Xcode Command Line Tools are required; run: xcode-select --install"
  fi
  xcode-select --install || true
  echo "Finish the Xcode Command Line Tools installer, then rerun this command."
  exit 2
fi

if ! command -v brew >/dev/null 2>&1; then
  if [[ "${CHECK_MODE}" == true || "${VERIFY_ONLY}" == true ]]; then
    die "Homebrew is required for check or verification mode"
  fi
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
  if [[ "${CHECK_MODE}" == true || "${VERIFY_ONLY}" == true ]]; then
    die "Ansible is required for check or verification mode"
  fi
  HOMEBREW_NO_AUTO_UPDATE=1 brew install ansible
fi

if ! ansible-galaxy collection list 2>/dev/null | grep -q '^community\.general'; then
  if [[ "${CHECK_MODE}" == true || "${VERIFY_ONLY}" == true ]]; then
    die "community.general is required; run: ansible-galaxy collection install -r setup/requirements.yml"
  fi
  ansible-galaxy collection install -r requirements.yml
fi

if [[ "${VERIFY_ONLY}" == true ]]; then
  exec ansible-playbook verify.yml --extra-vars "mac_profile=${PROFILE}"
fi

command=(ansible-playbook site.yml --extra-vars "mac_profile=${PROFILE}")
if [[ -n "${TAG}" ]]; then
  command+=(--tags "${TAG}")
fi
if [[ "${CHECK_MODE}" == true ]]; then
  command+=(--check --diff)
fi

echo "Applying Mac profile: ${PROFILE}"
[[ -z "${TAG}" ]] || echo "Selected area: ${TAG}"
"${command[@]}"
