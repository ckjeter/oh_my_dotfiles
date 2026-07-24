#!/usr/bin/env bash
# Wrapper to launch Claude Code with tmux agent-UI styling
# Usage: claude-tmux [args...] or alias claude to this

if [ -z "$TMUX" ]; then
  exec claude "$@"
fi

# Agent-UI pane styling (Catppuccin Mocha palette - subtle shift)
tmux set -p window-style 'fg=#cdd6f4,bg=#181825'
tmux set -p pane-border-style 'fg=#89b4fa'
tmux set -p pane-active-border-style 'fg=#89b4fa'
tmux select-pane -T 'Claude Code'

# Run Claude, then reset styling on exit
claude "$@"
rc=$?

tmux set -pu window-style
tmux set -pu pane-border-style
tmux set -pu pane-active-border-style
tmux select-pane -T ''

exit $rc
