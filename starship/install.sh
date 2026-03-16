#!/bin/sh
if ! command -v starship > /dev/null 2>&1; then
  brew install starship
fi

mkdir -p ~/.config
ln -sf ~/.dotfiles/starship/starship.toml.symlink ~/.config/starship.toml
