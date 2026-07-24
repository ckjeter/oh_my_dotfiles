#!/bin/sh
# Wire up per-machine shell config. See hosts/README.md.
set -e
. "$(dirname "$0")/../scripts/lib.sh"

# Resolved at shell start, not at install time, so a renamed machine just picks
# a different file or none at all.
zshrc_block host << EOF
_host_zsh="$DOTFILES/hosts/\$(hostname -s).zsh"
[ -f "\$_host_zsh" ] && source "\$_host_zsh"
unset _host_zsh
EOF

host_file="$DOTFILES/hosts/$(hostname -s).zsh"
if [ -f "$host_file" ]; then
  echo "using host config $host_file"
else
  echo "no host config for $(hostname -s). Create $host_file if this machine needs its own"
fi
