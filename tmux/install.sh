#!/bin/sh
set -e
. "$(dirname "$0")/../scripts/lib.sh"

link "$DOTFILES/tmux/tmux.symlink" "$HOME/.tmux.conf"

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# tpm installs into a running server, so start a throwaway one on its own socket
if [ -z "${DOTFILES_SKIP_PLUGINS:-}" ] && have tmux; then
  tmux -L dotfiles-install new-session -d 'sleep 300' 2>/dev/null || true
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" \
    || echo "tpm install failed, press prefix + I inside tmux"
  tmux -L dotfiles-install kill-server 2>/dev/null || true
elif ! have tmux; then
  echo "tmux is not installed, plugins skipped. Press prefix + I once it is"
fi
