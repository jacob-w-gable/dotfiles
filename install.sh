#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi

DISTRO=""
GUI=false
DEVEL=true
# Install everything under $HOME and never call sudo. For shared or centrally
# managed machines where the package and system steps are not ours to run.
USER_ONLY=false
# Convertible/2-in-1 support (touchscreen rotation, gestures, on-screen
# keyboard). Opt-in, because it installs extra packages and enables services
# that are useless on a machine that does not fold.
export DOTFILES_TABLET=false

usage() {
  echo "Usage: $0 [--distro <name>] [--gui] [--no-devel] [--tablet] [--user-only]"
  echo
  echo "  --distro <name>  ubuntu, fedora or arch. Autodetected when omitted."
  echo "  --gui            Also install and link the desktop configuration."
  echo "  --no-devel       Skip the language toolchains (Rust, Node)."
  echo "  --tablet         Include convertible/2-in-1 support."
  echo "  --user-only      Install into \$HOME only. No sudo, no packages, no"
  echo "                   system changes. Works on any distro and on aarch64."
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --distro)
    DISTRO="$2"
    shift 2
    ;;
  --gui)
    GUI=true
    shift
    ;;
  --no-devel)
    DEVEL=false
    shift
    ;;
  --tablet)
    export DOTFILES_TABLET=true
    shift
    ;;
  --user-only)
    USER_ONLY=true
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown argument: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

# The user-local path shares nothing with the system path: no distro script, no
# sudo, and no package installs. Handle it before anything asks for a password.
if [[ "$USER_ONLY" == true ]]; then
  if [[ "$GUI" == true ]]; then
    echo "--gui needs system packages and cannot be combined with --user-only" >&2
    exit 1
  fi
  ./install/common/user.sh
  ./install/common/link.sh
  exit 0
fi

DETECTED=""
if [[ -f /etc/os-release ]]; then
  DETECTED="$(. /etc/os-release && echo "$ID")"
fi

if [[ -z "$DISTRO" ]]; then
  DISTRO="$DETECTED"
fi

if [[ -z "$DISTRO" ]]; then
  if command -v apt &>/dev/null; then
    DISTRO="ubuntu"
  elif command -v dnf &>/dev/null; then
    DISTRO="fedora"
  elif command -v pacman &>/dev/null; then
    DISTRO="arch"
  fi
fi

if [[ ! -d "install/$DISTRO" ]]; then
  echo "Unsupported distro: ${DISTRO:-could not determine}" >&2
  echo "Supported: ubuntu, fedora, arch. Specify with --distro." >&2
  echo "For anything else, use --user-only to install into \$HOME." >&2
  exit 1
fi

# Forcing a distro this machine isn't runs package and repository steps built
# for a different system, and those steps fail quietly. On RHEL, the undefined
# %fedora rpm macro expands to a literal string, the download 404s, and the run
# continues.
if [[ -n "$DETECTED" && "$DISTRO" != "$DETECTED" ]]; then
  echo "Refusing to run the $DISTRO steps on $DETECTED." >&2
  echo "The package names and repositories differ and failures are silent." >&2
  echo "Use --user-only to install the configuration into \$HOME instead." >&2
  exit 1
fi

sudo -v

# Install packages, setup environment, link configs
"./install/$DISTRO/core.sh"
./install/common/core.sh --devel "$DEVEL"
./install/common/link.sh

# Optional GUI setup
if [[ "$GUI" == true ]]; then
  "./install/$DISTRO/gui.sh"
  ./install/common/gui.sh
  ./install/common/link_gui.sh
fi
