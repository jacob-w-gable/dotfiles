#!/usr/bin/env bash

set -eo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi
sudo -v

DISTRO=""
GUI=false
DEVEL=true

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
  -h | --help)
    echo "Usage: $0 [--distro <name>] [--gui] [--no-devel]"
    exit 0
    ;;
  *)
    echo "Unknown argument: $1"
    exit 1
    ;;
  esac
done

if [[ -z "$DISTRO" ]]; then
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO="$ID"
  fi
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

if [[ -z "$DISTRO" ]]; then
  echo "Could not determine distro. Please specify with --distro. Supported: ubuntu, fedora, arch"
  exit 1
fi

# Install packages, setup environment, link configs
./install/$DISTRO/core.sh
./install/common/core.sh --devel "$DEVEL"
./install/common/link.sh

# Optional GUI setup
if [[ "$GUI" == true ]]; then
  ./install/$DISTRO/gui.sh
  ./install/common/gui.sh
  ./install/common/link-gui.sh
fi
