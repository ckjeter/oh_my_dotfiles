#!/usr/bin/env bash
# tmux session archive: save, list, and restore individual sessions
# Usage: tmux-archive save [session] | list | restore <name> | delete <name>

set -euo pipefail

ARCHIVE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/archive"
mkdir -p "$ARCHIVE_DIR"

usage() {
  echo "Usage: tmux-archive <command> [args]"
  echo ""
  echo "Commands:"
  echo "  save [session]    Archive a session (default: current session)"
  echo "  list              List archived sessions"
  echo "  restore <name>    Restore an archived session"
  echo "  delete <name>     Delete an archived session"
  exit 1
}

# Dump a single session to resurrect-compatible format
save_session() {
  local session="${1:-$(tmux display-message -p '#S')}"

  if ! tmux has-session -t "$session" 2>/dev/null; then
    echo "Error: session '$session' does not exist"
    exit 1
  fi

  local timestamp
  timestamp=$(date +%Y%m%dT%H%M%S)
  local archive_file="$ARCHIVE_DIR/${session}__${timestamp}.txt"

  # Save window records
  tmux list-windows -t "$session" -F \
    "window	${session}	#{window_index}	#{window_name}	#{window_active}	#{window_flags}	#{window_layout}	#{automatic-rename}" \
    >> "$archive_file"

  # Save pane records
  tmux list-panes -s -t "$session" -F \
    "pane	${session}	#{window_index}	#{window_active}	#{window_flags}	#{pane_index}	#{pane_title}	#{pane_current_path}	#{pane_active}	#{pane_current_command}" \
    >> "$archive_file"

  echo "Archived '$session' -> $archive_file"
}

list_sessions() {
  if [ -z "$(ls -A "$ARCHIVE_DIR" 2>/dev/null)" ]; then
    echo "No archived sessions."
    return
  fi

  printf "%-20s %-25s %s\n" "SESSION" "ARCHIVED AT" "FILE"
  printf "%-20s %-25s %s\n" "-------" "-----------" "----"

  for f in "$ARCHIVE_DIR"/*.txt; do
    local basename
    basename=$(basename "$f" .txt)
    local name="${basename%%__*}"
    local ts="${basename##*__}"
    # Format timestamp for display
    local display_ts
    display_ts=$(echo "$ts" | sed 's/T/ /' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3/' | sed 's/ \([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/ \1:\2:\3/')
    printf "%-20s %-25s %s\n" "$name" "$display_ts" "$(basename "$f")"
  done
}

restore_session() {
  local name="$1"

  # Find the most recent archive for this session name
  local archive_file
  archive_file=$(ls -t "$ARCHIVE_DIR"/"${name}"__*.txt 2>/dev/null | head -1)

  if [ -z "$archive_file" ]; then
    echo "Error: no archive found for '$name'"
    echo "Available archives:"
    list_sessions
    exit 1
  fi

  if tmux has-session -t "$name" 2>/dev/null; then
    echo "Error: session '$name' already exists. Kill it first or choose a different name."
    exit 1
  fi

  echo "Restoring from: $(basename "$archive_file")"

  local first_window=true

  # Restore windows and panes
  while IFS=$'\t' read -r type session win_idx win_active win_flags pane_idx pane_title pane_path pane_active pane_cmd; do
    [ "$type" = "pane" ] || continue

    local dir="${pane_path/#\~/$HOME}"
    [ -d "$dir" ] || dir="$HOME"

    if $first_window; then
      tmux new-session -d -s "$name" -c "$dir"
      first_window=false
    elif [ "$pane_idx" = "0" ]; then
      tmux new-window -t "$name" -c "$dir"
    else
      tmux split-window -t "$name" -c "$dir"
    fi
  done < "$archive_file"

  # Apply window layouts
  while IFS=$'\t' read -r type session win_idx win_name win_active win_flags win_layout auto_rename; do
    [ "$type" = "window" ] || continue
    tmux rename-window -t "$name:$win_idx" "$win_name" 2>/dev/null || true
    tmux select-layout -t "$name:$win_idx" "$win_layout" 2>/dev/null || true
  done < "$archive_file"

  echo "Restored session '$name'"
}

delete_archive() {
  local name="$1"
  local count
  count=$(ls "$ARCHIVE_DIR"/"${name}"__*.txt 2>/dev/null | wc -l | tr -d ' ')

  if [ "$count" = "0" ]; then
    echo "Error: no archive found for '$name'"
    exit 1
  fi

  rm -f "$ARCHIVE_DIR"/"${name}"__*.txt
  echo "Deleted $count archive(s) for '$name'"
}

# Main
[ $# -ge 1 ] || usage

case "$1" in
  save)    save_session "${2:-}" ;;
  list)    list_sessions ;;
  restore) [ $# -ge 2 ] || { echo "Error: restore requires a session name"; exit 1; }; restore_session "$2" ;;
  delete)  [ $# -ge 2 ] || { echo "Error: delete requires a session name"; exit 1; }; delete_archive "$2" ;;
  *)       usage ;;
esac
