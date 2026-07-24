#!/bin/sh
# Claude Code status line. Wired into ~/.claude/settings.json by install.sh.
# POSIX sh on purpose: macOS runs this under bash-as-sh, Ubuntu under dash.
input=$(cat)

command -v jq > /dev/null 2>&1 || { echo 'statusline: install jq'; exit 0; }

jqr() { printf '%s' "$input" | jq -r "$1"; }

dir=$(jqr '.workspace.current_dir // .cwd')
case "$dir" in "$HOME"*) dir="~${dir#"$HOME"}" ;; esac
model=$(jqr '.model.display_name // .model.id')
ctx=$(jqr '.context_window.used_percentage // empty')
cost=$(jqr '.cost.total_cost_usd // 0')
# awk, because dash printf has no float conversions
cost_fmt=$(printf '%s' "$cost" | awk '{ printf "$%.2f", $0 }')
in_tok=$(jqr '.context_window.total_input_tokens // 0')
out_tok=$(jqr '.context_window.total_output_tokens // 0')
rate_5h=$(jqr '.rate_limits.five_hour.used_percentage // empty')
rate_7d=$(jqr '.rate_limits.seven_day.used_percentage // empty')
vim_mode=$(jqr '.vim.mode // empty')

# Gruvbox-inspired palette
BLUE='\033[34m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
DIM='\033[2m'
RESET='\033[0m'

# round to integer via awk; dash printf has no float conversions
trunc() { printf '%s' "$1" | awk '{ printf "%.0f", $0 }'; }

# Helper: threshold color (green < 50, yellow < 80, red >= 80)
tcolor() {
  val=$(trunc "$1")
  if [ "$val" -ge 80 ]; then printf "$RED"
  elif [ "$val" -ge 50 ]; then printf "$YELLOW"
  else printf "$GREEN"
  fi
}

SEP="${DIM}|${RESET}"

# -- Session --
out="${BLUE}${dir}${RESET} ${CYAN}${model}${RESET}"

# -- Context --
if [ -n "$ctx" ]; then
  cc=$(tcolor "$ctx")
  out="${out} ${SEP} ${cc}ctx:$(trunc "$ctx")%${RESET}"
fi

# -- Tokens + Cost --
out="${out} ${SEP} ${YELLOW}in:${in_tok} out:${out_tok}${RESET} ${GREEN}${cost_fmt}${RESET}"

# -- Rate Limits --
if [ -n "$rate_5h" ] || [ -n "$rate_7d" ]; then
  r5="${rate_5h:-0}"; r7="${rate_7d:-0}"
  r5c=$(tcolor "$r5"); r7c=$(tcolor "$r7")
  out="${out} ${SEP} ${r5c}5h:$(trunc "$r5")%${RESET} ${r7c}7d:$(trunc "$r7")%${RESET}"
fi

# -- Vim Mode --
if [ -n "$vim_mode" ]; then
  out="${out} ${SEP} ${YELLOW}${vim_mode}${RESET}"
fi

printf "%b\n" "$out"
