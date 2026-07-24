#!/bin/sh
# agent-history: the one place that knows how agent session history is read.
#
# Interface (everything else in this repo depends only on this):
#   agent-history.sh <dir>     sessions recorded under <dir>, most recent
#                              first, as TSV: agent TAB epoch TAB messages
#                              TAB resume-command. Missing backend or jq
#                              means empty output, never an error.
#   agent-history.sh --check   validate the backend contract; prints the
#                              reason and exits non-zero when broken.
#                              Wired into scripts/doctor.sh.
#
# Current backend: lazyagent (github.com/illegalstudio/lazyagent, MIT),
# through its documented CLI `lazyagent sessions --json --dir <dir>`. We
# deliberately depend only on documented JSON fields (agent, last_activity,
# messages, resume_command) and never parse its internal session stores:
# per-agent format churn is exactly what lazyagent maintains for us. If an
# upstream update changes this contract, this file is the only thing to fix,
# and until then the switcher preview just loses its history section.
#
# lazyagent takes 0.3-1.7s per call, so results are cached per directory.
set -u

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-mru/history"
TTL=300

JQ_PROGRAM='.[] | [
  (.agent // "?"),
  ((.last_activity // "") | sub("\\.[0-9]+"; "") | (try fromdateiso8601 catch 0)),
  (.messages // 0),
  (.resume_command // "")
] | @tsv'

check() {
  command -v lazyagent > /dev/null 2>&1 || { echo "lazyagent not installed"; exit 1; }
  command -v jq > /dev/null 2>&1        || { echo "jq not installed"; exit 1; }
  out="$(lazyagent sessions --json --dir "$HOME" 2>/dev/null)" \
    || { echo "lazyagent sessions --json failed"; exit 1; }
  printf '%s' "$out" | jq -e 'type == "array"' > /dev/null 2>&1 \
    || { echo "lazyagent sessions --json is not a JSON array"; exit 1; }
  printf '%s' "$out" | jq -e "$JQ_PROGRAM" > /dev/null 2>&1 \
    || { echo "lazyagent JSON no longer matches the fields this adapter reads"; exit 1; }
  echo "ok"
}

case "${1:-}" in
  --check) check; exit 0 ;;
  '') echo "usage: $0 <dir> | --check" >&2; exit 2 ;;
esac

dir="$1"
command -v lazyagent > /dev/null 2>&1 || exit 0
command -v jq > /dev/null 2>&1        || exit 0

mkdir -p "$CACHE_DIR"
key="$(printf '%s' "$dir" | cksum | cut -d' ' -f1)"
cache="$CACHE_DIR/$key.tsv"

if [ -f "$cache" ]; then
  age=$(( $(date +%s) - $(awk 'NR == 1 { print $1; exit }' "$cache.stamp" 2>/dev/null || echo 0) ))
  [ "$age" -lt "$TTL" ] && { cat "$cache"; exit 0; }
fi

lazyagent sessions --json --dir "$dir" 2>/dev/null \
  | jq -r "$JQ_PROGRAM" 2>/dev/null \
  | sort -t "$(printf '\t')" -k2,2 -rn > "$cache.tmp.$$" \
  && mv "$cache.tmp.$$" "$cache" \
  && date +%s > "$cache.stamp"
cat "$cache" 2>/dev/null
