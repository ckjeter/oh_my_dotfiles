#!/bin/sh
# Copy a local terminfo entry to a remote host so ncurses apps there understand
# $TERM. Servers do not ship Ghostty's entry, which breaks colors and keys.
# Run this from the laptop:
#
#   scripts/push-terminfo.sh kuan@147.224.196.198
#   scripts/push-terminfo.sh kuan@host xterm-kitty
set -e

host="$1"
term="${2:-xterm-ghostty}"

if [ -z "$host" ]; then
  echo "usage: $0 <ssh-host> [term-name]" >&2
  exit 1
fi

infocmp -x "$term" | ssh "$host" -- tic -x -
echo "installed $term terminfo on $host"
