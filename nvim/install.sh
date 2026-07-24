#!/bin/sh
# primary editor is Cursor, this config is for quick terminal edits only
set -e
. "$(dirname "$0")/../scripts/lib.sh"

link "$DOTFILES/nvim/nvim.symlink" "$HOME/.vimrc"
link "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"

# vim-plug is the plugin manager the vimrc calls, not a system package
curl -fsSLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [ -n "${DOTFILES_SKIP_PLUGINS:-}" ]; then
  echo "DOTFILES_SKIP_PLUGINS set, run ':PlugInstall' yourself"
elif have nvim; then
  nvim --headless +PlugInstall +qall
else
  echo "nvim is not installed, run ':PlugInstall' once it is"
fi
