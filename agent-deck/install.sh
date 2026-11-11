#!/bin/sh
# agent-deck rewrites its own config.toml at runtime (comments and order do not
# survive), so the file stays the machine's. This adds the [tmux] tables from
# agent-deck/tmux.toml when the file has none, and otherwise only checks them.
set -e
. "$(dirname "$0")/../scripts/lib.sh"

conf="${XDG_CONFIG_HOME:-$HOME/.config}/agent-deck/config.toml"

if [ ! -f "$conf" ] || ! grep -q '^[[:space:]]*\[tmux' "$conf"; then
  mkdir -p "$(dirname "$conf")"
  { echo; cat "$DOTFILES/agent-deck/tmux.toml"; } >> "$conf"
  echo "agent-deck [tmux] settings -> $conf"
elif ! grep -qF 'socket_name = "agent-deck"' "$conf" \
  || ! grep -qF 'status-right = "#{E:@status_right_main}"' "$conf"; then
  echo "$conf has its own [tmux] section that differs from $DOTFILES/agent-deck/tmux.toml, merge by hand"
fi
if ! grep -q '^[[:space:]]*\[tools\.pi\]' "$conf"; then
  { echo; cat "$DOTFILES/agent-deck/pi.toml"; } >> "$conf"
  echo "agent-deck Pi footer detection -> $conf"
elif ! grep -qF 'ctx:(?:' "$conf"; then
  echo "$conf has its own [tools.pi] section, merge $DOTFILES/agent-deck/pi.toml by hand"
fi
have agent-deck || echo "agent-deck is not installed, its config is ready for when it is"
