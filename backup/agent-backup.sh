#!/bin/sh
# Copy agent session data to an encrypted rclone remote, one folder per machine.
#
#   sh backup/agent-backup.sh             # upload
#   sh backup/agent-backup.sh --dry-run   # show what would be uploaded
#
# The remote must be an rclone crypt remote, so nothing leaves this machine in
# the clear. Its name comes from AGENT_BACKUP_REMOTE (default "agentbak:").
# The crypt password lives in the machine-local rclone.conf, never in this repo.
#
# It uses "rclone copy", not "sync": a file deleted here stays in the backup.
set -u

REMOTE="${AGENT_BACKUP_REMOTE:-agentbak:}"
name="${REMOTE%:}"
# macOS renumbers its local hostname (Name-2, Name-3, ...) whenever it sees a
# name clash on the network, which would start a new backup folder each time.
# The computer name does not drift.
machine_name() {
  if [ -n "${AGENT_BACKUP_NAME:-}" ]; then
    printf '%s\n' "$AGENT_BACKUP_NAME"
  elif [ -x /usr/sbin/scutil ]; then
    /usr/sbin/scutil --get ComputerName | tr ' ' '-' | LC_ALL=C tr -cd 'A-Za-z0-9-'
  else
    hostname -s
  fi
}
dest="$REMOTE$(machine_name)"
stage="${XDG_CACHE_HOME:-$HOME/.cache}/agent-backup"
fail=0
dry=""
[ "${1:-}" = --dry-run ] && dry=--dry-run

command -v rclone > /dev/null 2>&1 || { echo "rclone is not installed" >&2; exit 1; }

type=$(rclone config show "$name" 2> /dev/null | awk -F ' = ' '$1 == "type" { print $2 }')
if [ "$type" != crypt ]; then
  echo "rclone remote '$name' is missing or not a crypt remote, refusing to upload" >&2
  exit 1
fi

# --local-no-check-updated: live sessions append to their transcript while it
# uploads. Take what is there and let the next run pick up the rest.
rc() { rclone "$@" $dry --local-no-check-updated --transfers 4 --stats-one-line --stats 0; }

copy_dir() {
  [ -d "$1" ] || return 0
  echo "==> $1"
  rc copy "$1" "$dest/$2" || fail=1
}

copy_file() {
  [ -f "$1" ] || return 0
  echo "==> $1"
  rc copyto "$1" "$dest/$2" || fail=1
}

# A live SQLite file copied as-is can be torn. Take a consistent snapshot first.
snapshot_db() {
  mkdir -p "$(dirname "$2")"
  python3 - "$1" "$2" << 'EOF' || { echo "snapshot failed: $1" >&2; fail=1; }
import sqlite3, sys
src = sqlite3.connect("file:" + sys.argv[1] + "?mode=ro", uri=True, timeout=30)
dst = sqlite3.connect(sys.argv[2])
src.backup(dst)
dst.close()
src.close()
EOF
}

copy_dir "$HOME/.claude/projects" claude/projects
copy_file "$HOME/.claude/history.jsonl" claude/history.jsonl
copy_dir "$HOME/.codex/sessions" codex/sessions
copy_dir "$HOME/.codex/archived_sessions" codex/archived_sessions
copy_file "$HOME/.codex/history.jsonl" codex/history.jsonl
copy_file "$HOME/.codex/session_index.jsonl" codex/session_index.jsonl
copy_dir "$HOME/.pi/agent/sessions" pi/sessions
copy_dir "$HOME/.local/share/leader" leader

rm -rf "$stage"
for db in "$HOME"/.local/share/agent-deck/profiles/*/state.db; do
  [ -f "$db" ] || continue
  snapshot_db "$db" "$stage/$(basename "$(dirname "$db")")/state.db"
done
copy_dir "$stage" agent-deck
rm -rf "$stage"

if [ "$fail" -ne 0 ]; then
  echo "agent backup finished with errors" >&2
  exit 1
fi
echo "agent backup ok -> $dest"
