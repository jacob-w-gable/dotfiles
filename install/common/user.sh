#!/usr/bin/env bash
# User-local install.
#
# Everything lands under $HOME. No sudo, no package manager, and nothing that
# another account on the machine can see. This is the mode for a shared or
# centrally managed host where the distro package steps are not ours to run.
#
# The tools that only ship as distro packages (zsh, tmux, git, ranger, btop,
# bat, fd) are assumed to be present already, and the script lists any that are
# missing before it starts. Only software published as a portable release binary
# is installed here.

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" >&2
  exit 1
fi

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Pinned so an upstream release cannot change what this script installs without
# a commit here. Bump deliberately.
EZA_VERSION="0.23.4"

BIN_DIR="$HOME/.local/bin"
OPT_DIR="$HOME/.local/opt"
mkdir -p "$BIN_DIR" "$OPT_DIR"

# Unpack in a temporary directory so a failed download cannot leave an archive
# behind in the repository, and so cleanup needs no bookkeeping.
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# Report the tools this mode cannot install, rather than failing later inside a
# config that assumes they exist.
echo "==> checking for packages this mode cannot install"
missing=()
for cmd in zsh tmux git curl ranger btop bat fd; do
  command -v "$cmd" &>/dev/null || missing+=("$cmd")
done
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "  not found: ${missing[*]}"
  echo "  ask an administrator to install these, or the config will be degraded"
else
  echo "  all present"
fi

echo "==> neovim -> $OPT_DIR/nvim-linux-$ARCH_NVIM"
curl -fsSL -o "$WORK_DIR/nvim.tar.gz" \
  "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$ARCH_NVIM.tar.gz"
rm -rf "${OPT_DIR:?}/nvim-linux-$ARCH_NVIM"
tar -C "$OPT_DIR" -xzf "$WORK_DIR/nvim.tar.gz"
ln -sfn "$OPT_DIR/nvim-linux-$ARCH_NVIM/bin/nvim" "$BIN_DIR/nvim"

echo "==> eza -> $BIN_DIR/eza"
curl -fsSL -o "$WORK_DIR/eza.tar.gz" \
  "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/eza_$ARCH_RUST-unknown-linux-gnu.tar.gz"
tar -C "$WORK_DIR" -xzf "$WORK_DIR/eza.tar.gz"
install -m 755 "$WORK_DIR/eza" "$BIN_DIR/eza"

echo "==> lazygit -> $BIN_DIR/lazygit"
LAZYGIT_VERSION="$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" |
  grep -Po '"tag_name": "v\K[^"]*')"
curl -fsSL -o "$WORK_DIR/lazygit.tar.gz" \
  "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_linux_${ARCH_LAZYGIT}.tar.gz"
tar -C "$WORK_DIR" -xzf "$WORK_DIR/lazygit.tar.gz" lazygit
install -m 755 "$WORK_DIR/lazygit" "$BIN_DIR/lazygit"

echo "==> tmux plugin manager"
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# --no-update-rc keeps fzf out of ~/.bashrc, which is the startup file the
# account actually logs in with on a borrowed machine. The generated .zshrc
# below sources ~/.fzf.zsh explicitly instead.
echo "==> fzf"
if [[ ! -d "$HOME/.fzf" ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
fi
"$HOME/.fzf/install" --all --no-update-rc

echo "==> .zshrc"
backup_path "$HOME/.zshrc"
cat >"$HOME/.zshrc" <<'ZSHRC'
source ~/.zshrc-core
[[ ! -f ~/.fzf.zsh ]] || source ~/.fzf.zsh
ZSHRC

# The login shell is left alone on purpose. chsh edits a system account
# database and may be denied outright on a centrally managed host.
echo
echo "Done. Nothing outside \$HOME was modified and the login shell is unchanged."
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "Note: $BIN_DIR is not on PATH in this shell; .zshrc-core adds it for zsh."
fi
echo "To try it:    zsh"
echo "To adopt it:  chsh -s \"\$(command -v zsh)\""
