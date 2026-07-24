#!/bin/sh
# Point Claude Code's status line at the tracked script.
#
# ~/.claude/settings.json is machine-local (permissions, hooks, model prefs
# accumulate there), so this never replaces the file: it surgically sets the
# one statusLine key with jq and leaves everything else alone.
set -e
. "$(dirname "$0")/../scripts/lib.sh"

if ! have jq; then
  echo "jq is missing, statusline not wired. See scripts/requirements.tsv"
  exit 0
fi

settings="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"
[ -f "$settings" ] || printf '{}\n' > "$settings"

cmd="sh $DOTFILES/claude/statusline.sh"
current="$(jq -r '.statusLine.command // ""' "$settings")"
if [ "$current" = "$cmd" ]; then
  exit 0
fi

tmp="$settings.dotfiles-tmp"
jq --arg cmd "$cmd" '.statusLine = { type: "command", command: $cmd }' \
  "$settings" > "$tmp" && mv "$tmp" "$settings"
echo "statusLine -> $DOTFILES/claude/statusline.sh"
