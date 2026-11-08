#!/bin/sh
# Put a divider in front of the first window whenever status-left has text
# (agent-deck's notification bar, or the hostname badge on servers), so the
# two do not run together. Runs after tpm because the theme sets the window
# formats while it loads. The marker check keeps a reload from stacking it.
divider='#{?#{&&:#{window_start_flag},#{status-left}},#[fg=#6c7086] │ #[default],}'
for opt in window-status-format window-status-current-format; do
  current=$(tmux show -gv "$opt")
  case "$current" in
    "$divider"*) ;;
    *) tmux set -g "$opt" "$divider$current" ;;
  esac
done
