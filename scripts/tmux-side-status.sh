#!/bin/sh
# Status bar for side servers (agent-deck). agent-deck owns status-left and
# rewrites it whole for its notification bar, so the rest goes in front of the
# first window instead: a divider when the bar shows, then the session's
# agent-deck group in the same pill the main server uses for the session name.
# Runs after tpm, which rebuilds the window formats on every load.
tmux set -g @agentdeck_group_pill "$(tmux show -gv @catppuccin_status_session \
  | sed 's/#{E:@catppuccin_session_text}/ #{@agentdeck_group_path}/')#[default] "
prefix='#{?window_start_flag,#{?status-left,#[fg=#6c7086] │ #[default],}#{?@agentdeck_group_path,#{E:@agentdeck_group_pill},},}'
for opt in window-status-format window-status-current-format; do
  tmux set -g "$opt" "$prefix$(tmux show -gv "$opt")"
done
