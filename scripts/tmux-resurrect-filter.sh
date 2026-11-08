#!/bin/sh
# tmux-resurrect post-save-layout hook: drop agent-deck sessions from a save
# file. agent-deck brings its own sessions back with `agent-deck fleet recover`,
# and a restored copy would only be an empty shell under a stale name.
file="$1"
[ -f "$file" ] || exit 0
awk -F '\t' '$2 !~ /^agentdeck_/' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
