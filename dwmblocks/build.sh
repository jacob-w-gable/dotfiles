#!/usr/bin/env bash
#
# Build dwmblocks, the status bar for the variant without polybar.
#
# This is the LukeSmithxyz fork rather than torrinfail's, because it reads the
# click byte the dwm statuscmd patch sends and exports it as BLOCK_BUTTON. The
# upstream one only supports signals, so no block would be clickable.
#
# Installs to ~/.local/bin. Set PREFIX to install elsewhere.

set -euo pipefail

readonly here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly build_dir=$here/build
readonly prefix=${PREFIX:-$HOME/.local}
readonly repo=https://codeload.github.com/LukeSmithxyz/dwmblocks/tar.gz/refs/heads/master

# Longest single block output, in bytes. The default 50 truncates ours: the
# status2d colour codes are 10 bytes a pair and the now-playing block allows 40
# characters of track name on top of that.
readonly cmd_length=192

log() { printf '\033[1;34m::\033[0m %s\n' "$*"; }

rm -rf "$build_dir"
mkdir -p "$build_dir"

log "downloading dwmblocks"
curl -fsSL "$repo" | tar xz -C "$build_dir" --strip-components=1

cp "$here/config.h" "$build_dir/config.h"
sed -i "s/^#define CMDLENGTH.*/#define CMDLENGTH\t\t$cmd_length/" \
    "$build_dir/dwmblocks.c"

log "compiling"
make -C "$build_dir" >/dev/null

mkdir -p "$prefix/bin"
install -m755 "$build_dir/dwmblocks" "$prefix/bin/dwmblocks"
log "installed $prefix/bin/dwmblocks"
