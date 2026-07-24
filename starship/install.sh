#!/bin/sh
set -e
. "$(dirname "$0")/../scripts/lib.sh"

link "$DOTFILES/starship/starship.toml.symlink" "$HOME/.config/starship.toml"

# guarded, so the zshrc still works on a machine where starship is missing
zshrc_block starship << 'EOF'
command -v starship > /dev/null && eval "$(starship init zsh)"
EOF
