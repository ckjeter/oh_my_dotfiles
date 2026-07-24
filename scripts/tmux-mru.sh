#!/bin/sh
# MRU window switcher with agent and git context, driven from prefix + Tab.
#
# The popup must render instantly, so the work is split by latency budget:
#   tier 0  cmd_list     one tmux call + one awk pass. MRU order, window
#                        names, agent badges. Blocking, target < 100ms.
#   tier 1  refresh-git  git branch + dirty count per window, cached with a
#                        TTL and refreshed in the background on popup open.
#                        The list reads the cache and never runs git itself.
#   tier 2  cmd_preview  detail for the one highlighted window: live panes,
#                        live git, agent session history via agent-history.sh.
#
# Subcommands:
#   record <session:window>   called from tmux hooks; maintains the MRU stack
#   list                      emit the fzf input (also used by ctrl-r reload)
#   switch                    the prefix + Tab popup
#   preview <session:window>  expanded detail for the fzf preview pane
#   refresh-git               update stale git cache entries, then exit
set -u

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tmux"
STACK="$STATE_DIR/mru.stack"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-mru"
GIT_CACHE="$CACHE_DIR/git.tsv"
GIT_TTL=120
MAX=20
AGENT_MARK='✳ '
# fallback detection by foreground command; the ✳ pane title is the primary
AGENT_CMDS='claude kimi codex aider goose opencode amp grok cursor pi kilo'
# one symbol per platform, shown once per agent pane (✳✳ = two claude panes).
# claude gets its own spinner mark; kimi is Moonshot, hence the moon.
AGENT_ICONS='claude=✳ kimi=🌙 codex=⬡ copilot=🚁 cursor=▌ amp=⚡ goose=🪿 grok=✖ pi=π'
AGENT_ICON_DEFAULT='✱'
TAB="$(printf '\t')"
HISTORY_HELPER="$(dirname "$0")/agent-history.sh"

# ---------- record ----------------------------------------------------------

# stack line: <session:window> TAB <epoch of that focus>
cmd_record() {
  target="${1:-}"
  [ -n "$target" ] || exit 0
  mkdir -p "$STATE_DIR"
  tmp="$STACK.tmp.$$"
  { printf '%s\t%s\n' "$target" "$(date +%s)"; cat "$STACK" 2>/dev/null; } \
    | awk -F "$TAB" '!seen[$1]++' | head -n "$MAX" > "$tmp" && mv "$tmp" "$STACK"
}

# ---------- list (tier 0) ----------------------------------------------------

# Emits: <target> TAB <display line>, MRU first. One tmux call, one awk pass.
cmd_list() {
  cur="$(tmux display-message -p '#{session_name}:#{window_index}' 2>/dev/null || true)"
  tmux list-panes -a -F "#{session_name}:#{window_index}${TAB}#{window_name}${TAB}#{pane_active}${TAB}#{pane_title}${TAB}#{pane_current_command}${TAB}#{pane_current_path}${TAB}#{pane_activity}" 2>/dev/null \
  | awk -F "$TAB" \
      -v now="$(date +%s)" -v cur="$cur" -v mark="$AGENT_MARK" \
      -v cmds="$AGENT_CMDS" -v icons="$AGENT_ICONS" -v defic="$AGENT_ICON_DEFAULT" \
      -v stack="$STACK" -v gitcache="$GIT_CACHE" '
    function rel(s) {
      if (s < 60)    return s "s"
      if (s < 3600)  return int(s / 60) "m"
      if (s < 86400) return int(s / 3600) "h"
      return int(s / 86400) "d"
    }
    function iconof(kind) { return (kind in icon) ? icon[kind] : defic }
    BEGIN {
      n = split(cmds, ca, " "); for (i = 1; i <= n; i++) agentcmd[ca[i]] = 1
      n = split(icons, ia, " ")
      for (i = 1; i <= n; i++) { split(ia[i], kv, "="); icon[kv[1]] = kv[2] }
      r = 0
      while ((getline line < stack) > 0) {
        split(line, f, "\t")            # target [epoch]
        r++
        if (!(f[1] in rank)) { rank[f[1]] = r; lastseen[f[1]] = f[2] }
      }
      close(stack)
      while ((getline line < gitcache) > 0) {
        split(line, g, "\t")            # path  branch  dirty  epoch
        gbranch[g[1]] = g[2]; gdirty[g[1]] = g[3]
      }
      close(gitcache)
    }
    {
      win = $1; name = $2; active = $3; title = $4; cmd = $5; path = $6; act = $7
      if (!(win in seen)) { seen[win] = 1; order[++m] = win; wname[win] = name }
      task = ""; kind = ""
      if (index(title, mark) == 1)  { task = substr(title, length(mark) + 1); kind = "claude" }
      else if (cmd in agentcmd)     { task = "running " cmd; kind = cmd }
      if (task != "") {
        aicons[win] = aicons[win] iconof(kind)
        # remember the first agent task; TUI spinners keep pane_activity
        # fresh, so output-idle is useless as a staleness signal here
        if (!(win in atask)) atask[win] = task
      }
      if (active == 1 || !(win in wpath)) wpath[win] = path
    }
    END {
      for (i = 1; i <= m; i++) {
        win = order[i]
        if (win == cur) continue
        # age = how long since YOU last focused this window; this is what
        # makes a session you opened days ago and forgot stand out
        age = ""
        if ((win in lastseen) && lastseen[win] != "")
          age = rel(now - lastseen[win])
        p = wpath[win]; badge = ""
        if ((p in gbranch) && gbranch[p] != "") {
          badge = "[" gbranch[p] (gdirty[p] > 0 ? " +" gdirty[p] : "") "]"
        }
        ab = ""
        if (win in aicons)
          ab = sprintf("%s %s", aicons[win], atask[win])
        line = sprintf("%-18s %-14s %5s  %-16s %s", win, wname[win], age, badge, ab)
        printf "%04d\t%s\t%s\n", (win in rank ? rank[win] : 1000 + i), win, line
      }
    }
  ' | sort -n | cut -f2,3
}

# ---------- switch -----------------------------------------------------------

cmd_switch() {
  self="$0"
  # tier 1: refresh the git cache while the user is already looking at the list
  ( "$self" refresh-git > /dev/null 2>&1 & )
  sel="$(cmd_list | fzf --no-sort --reverse --prompt='switch> ' \
          --delimiter="$TAB" --with-nth=2 \
          --preview="$self preview {1}" --preview-window='right,55%,wrap' \
          --bind="ctrl-r:reload($self list)" \
        | cut -f1)"
  [ -n "$sel" ] && tmux switch-client -t "$sel"
}

# ---------- git cache (tier 1) -----------------------------------------------

cmd_refresh_git() {
  mkdir -p "$CACHE_DIR"
  now="$(date +%s)"
  tmux list-panes -a -F "#{pane_active}${TAB}#{pane_current_path}" 2>/dev/null \
    | awk -F "$TAB" '$1 == 1 && !seen[$2]++ { print $2 }' \
    | while IFS= read -r p; do
        if [ -f "$GIT_CACHE" ]; then
          epoch="$(awk -F "$TAB" -v p="$p" '$1 == p { e = $4 } END { print e }' "$GIT_CACHE")"
          [ -n "$epoch" ] && [ $((now - epoch)) -lt "$GIT_TTL" ] && continue
        fi
        # symbolic-ref also answers on a repo with no commits yet, where
        # rev-parse --abbrev-ref degrades to the literal string HEAD
        branch="$(git -C "$p" symbolic-ref --short -q HEAD 2>/dev/null \
          || git -C "$p" rev-parse --short HEAD 2>/dev/null || true)"
        dirty=0
        [ -n "$branch" ] && dirty="$(git -C "$p" status --porcelain --no-renames 2>/dev/null | wc -l | tr -d ' ')"
        tmp="$GIT_CACHE.tmp.$$"
        {
          [ -f "$GIT_CACHE" ] && awk -F "$TAB" -v p="$p" '$1 != p' "$GIT_CACHE"
          printf '%s\t%s\t%s\t%s\n' "$p" "$branch" "$dirty" "$now"
        } > "$tmp" && mv "$tmp" "$GIT_CACHE"
      done
}

# ---------- preview (tier 2) -------------------------------------------------

reltime() {
  s="$1"
  if   [ "$s" -lt 60 ];    then echo "${s}s"
  elif [ "$s" -lt 3600 ];  then echo "$((s / 60))m"
  elif [ "$s" -lt 86400 ]; then echo "$((s / 3600))h"
  else                          echo "$((s / 86400))d"
  fi
}

cmd_preview() {
  win="${1:-}"
  [ -n "$win" ] || return 0
  now="$(date +%s)"
  info="$(tmux list-panes -t "$win" -F "#{window_name}${TAB}#{pane_index}${TAB}#{pane_active}${TAB}#{pane_title}${TAB}#{pane_current_command}${TAB}#{pane_current_path}${TAB}#{pane_activity}" 2>/dev/null)"
  [ -n "$info" ] || { echo "window is gone"; return 0; }

  # awk, not a shell read loop: TAB is IFS whitespace, so read collapses
  # empty fields (an empty pane title shifts every later column)
  printf '%s\n' "$info" | awk -F "$TAB" \
      -v mark="$AGENT_MARK" -v cmds="$AGENT_CMDS" -v icons="$AGENT_ICONS" \
      -v defic="$AGENT_ICON_DEFAULT" -v home="$HOME" -v win="$win" '
    function iconof(kind) { return (kind in icon) ? icon[kind] : defic }
    BEGIN {
      n = split(cmds, ca, " "); for (i = 1; i <= n; i++) agentcmd[ca[i]] = 1
      n = split(icons, ia, " ")
      for (i = 1; i <= n; i++) { split(ia[i], kv, "="); icon[kv[1]] = kv[2] }
    }
    {
      if (NR == 1) printf "%s  %s\n", win, $1
      task = ""; kind = ""
      if (index($4, mark) == 1)   { task = substr($4, length(mark) + 1); kind = "claude" }
      else if ($5 in agentcmd)    { task = "running " $5; kind = $5 }
      if (task != "") agents = agents sprintf("  %s pane %s  %s\n", iconof(kind), $2, task)
      p = $6; sub("^" home, "~", p)
      panes = panes sprintf("  %s%s %-12s %s\n", $2, ($3 == 1 ? "*" : " "), $5, p)
    }
    END {
      if (agents != "") printf "\nagents:\n%s", agents
      printf "\npanes:\n%s", panes
    }
  '

  # live git for just this window's active pane path
  p="$(printf '%s\n' "$info" | awk -F "$TAB" '$3 == 1 { print $6; exit }')"
  [ -n "$p" ] || p="$(printf '%s\n' "$info" | head -1 | cut -f6)"
  branch="$(git -C "$p" symbolic-ref --short -q HEAD 2>/dev/null \
    || git -C "$p" rev-parse --short HEAD 2>/dev/null || true)"
  if [ -n "$branch" ]; then
    changed="$(git -C "$p" status --porcelain --no-renames 2>/dev/null | wc -l | tr -d ' ')"
    printf '\ngit: %s, %s changed\n' "$branch" "$changed"
    git -C "$p" status --porcelain --no-renames 2>/dev/null | head -6 | sed 's/^/  /'
    git -C "$p" log -1 --format='  last: %s (%cr)' 2>/dev/null
  fi

  # agent session history for that path, via the adapter (empty when the
  # adapter's backend or jq is missing; the section simply disappears)
  if [ -x "$HISTORY_HELPER" ]; then
    hist="$("$HISTORY_HELPER" "$p" 2>/dev/null | head -5)"
    if [ -n "$hist" ]; then
      printf '\nhistory:\n'
      printf '%s\n' "$hist" | while IFS="$TAB" read -r agent epoch msgs resume; do
        age=$((now - epoch)); [ "$epoch" -gt 0 ] 2>/dev/null || age=0
        printf '  %-9s %-5s %4s msgs  %s\n' "$agent" "$(reltime "$age")" "$msgs" "$resume"
      done
    fi
  fi
}

# ---------- dispatch ---------------------------------------------------------

case "${1:-}" in
  record)      shift; cmd_record "${1:-}" ;;
  list)        cmd_list ;;
  switch)      cmd_switch ;;
  preview)     shift; cmd_preview "${1:-}" ;;
  refresh-git) cmd_refresh_git ;;
  *) echo "usage: $0 {record <target>|list|switch|preview <target>|refresh-git}" >&2; exit 2 ;;
esac
