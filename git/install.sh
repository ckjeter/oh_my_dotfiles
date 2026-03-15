#!/bin/sh
# symlink gitconfig — edit git/gitconfig.symlink directly for personal settings
ln -sf ~/.dotfiles/git/gitconfig.symlink ~/.gitconfig

# required for GPG passphrase prompt in interactive shells
if tty > /dev/null 2>&1; then
  echo "export GPG_TTY=$(tty)" >> ~/.zshrc
fi
