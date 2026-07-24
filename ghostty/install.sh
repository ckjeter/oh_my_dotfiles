#!/bin/sh
set -e
. "$(dirname "$0")/../scripts/lib.sh"

link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
link "$DOTFILES/ghostty/themes/catppuccin-mocha.conf" "$HOME/.config/ghostty/themes/catppuccin-mocha.conf"
link "$DOTFILES/ghostty/themes/catppuccin-macchiato.conf" "$HOME/.config/ghostty/themes/catppuccin-macchiato.conf"
