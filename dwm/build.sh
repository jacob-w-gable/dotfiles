#!/usr/bin/env bash
#
# Build dwm from the upstream tarball plus the patches in patches/.
#
# The dwm source is not checked in. This script downloads dwm-6.5.tar.gz,
# verifies it against the sha256 below, applies every patch in patches/ in
# filename order, and drops config.h in before running make. Only the patches
# and config.h are ours, so a version bump is a new tarball and a re-test of
# the stack rather than a merge into vendored C.
#
# Installs to ~/.local/bin by default, which needs no root. Set PREFIX to
# install elsewhere.

set -euo pipefail

readonly DWM_VERSION=6.5
readonly DWM_SHA256=21d79ebfa9f2fb93141836c2666cb81f4784c69d64e7f1b2352f9b970ba09729

readonly here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly build_dir=$here/build
readonly cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/dwm-src
readonly tarball=$cache_dir/dwm-$DWM_VERSION.tar.gz
readonly prefix=${PREFIX:-$HOME/.local}

log() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m!!\033[0m %s\n' "$*" >&2; exit 1; }

fetch_source() {
    mkdir -p "$cache_dir"
    if [[ ! -f $tarball ]]; then
        log "downloading dwm $DWM_VERSION"
        curl -fsSL -o "$tarball" \
            "https://dl.suckless.org/dwm/dwm-$DWM_VERSION.tar.gz"
    fi

    # A truncated download would otherwise fail much later, in the middle of
    # the patch stack, where the real cause is no longer obvious.
    local actual
    actual=$(sha256sum "$tarball" | cut -d' ' -f1)
    [[ $actual == "$DWM_SHA256" ]] ||
        die "checksum mismatch on $tarball (got $actual). Delete it and retry."
}

# Unpack into a scratch tree, so a failed patch never leaves a half-patched
# source behind for the next run to build.
unpack_source() {
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    tar xzf "$tarball" -C "$build_dir" --strip-components=1
}

apply_patches() {
    local patch_file
    for patch_file in "$here"/patches/*.diff; do
        log "applying $(basename "$patch_file")"
        patch -d "$build_dir" -p1 --forward --no-backup-if-mismatch \
            < "$patch_file" ||
            die "$(basename "$patch_file") did not apply"
    done
}

# config.h overrides the config.def.h the patches have been editing, so it is
# copied after them. config.mk points the build at $prefix.
configure() {
    cp "$here/config.h" "$here/helpers.c" "$build_dir/"
    bash "$here/gen-colors.sh" "$build_dir/colors.h"
    sed -i "s|^PREFIX = .*|PREFIX = $prefix|" "$build_dir/config.mk"

    # Ubuntu keeps the X headers under /usr/include/X11, which dwm's default
    # /usr/X11R6 include path does not cover.
    sed -i "s|^X11INC = .*|X11INC = /usr/include/X11|" "$build_dir/config.mk"
    sed -i "s|^X11LIB = .*|X11LIB = /usr/lib/x86_64-linux-gnu|" "$build_dir/config.mk"
}

main() {
    fetch_source
    unpack_source
    apply_patches
    configure

    log "compiling"
    make -C "$build_dir" -j"$(nproc)" >/dev/null

    mkdir -p "$prefix/bin"
    install -m755 "$build_dir/dwm" "$prefix/bin/dwm"
    log "installed $prefix/bin/dwm"
}

main "$@"
