#!/bin/sh
# Shared helpers for the per-tool install scripts.
# Source it with: . "$(dirname "$0")/../scripts/lib.sh"
#
# Nothing here installs a tool. The scripts wire up config and report what is
# missing; installing is the operator's call, since several of these tools want
# an interactive setup step.
#
# Env switches:
#   DOTFILES_SKIP_PLUGINS=1  do not download tmux/nvim plugins

# repo root, derived from the calling script so a clone outside ~ still works.
# The root install.sh exports DOTFILES itself because $0 is one level higher there.
DOTFILES="${DOTFILES:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"

have() { command -v "$1" > /dev/null 2>&1; }

os_family() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux) echo linux ;;
    *) echo unknown ;;
  esac
}

# architecture slug used in the neovim release filenames
arch_slug() {
  case "$(uname -m)" in
    aarch64 | arm64) echo arm64 ;;
    x86_64 | amd64) echo x86_64 ;;
    *) uname -m ;;
  esac
}

# Walk scripts/requirements.tsv and call <callback> for every tool this machine
# is missing, with: tool, need, why, install command for this OS.
# Pass "required" as the filter to skip optional tools.
_each_missing_tool() {
  _only="$1"
  _cb="$2"
  _os=$(os_family)
  _arch=$(arch_slug)
  while IFS='	' read -r _tool _need _why _mac _linux; do
    case "$_tool" in '' | \#*) continue ;; esac
    if [ "$_only" = required ] && [ "$_need" != required ]; then continue; fi
    if have "$_tool"; then continue; fi
    if [ "$_os" = macos ]; then _cmd="$_mac"; else _cmd="$_linux"; fi
    _cmd=$(printf '%s' "$_cmd" | sed "s/{arch}/$_arch/g")
    "$_cb" "$_tool" "$_need" "$_why" "$_cmd"
  done < "$DOTFILES/scripts/requirements.tsv"
}

_report_missing_tool() {
  if [ "${_missing_shown:-0}" -eq 0 ]; then
    printf '\nMissing tools. Nothing in this repo installs them:\n'
    _missing_shown=1
  fi
  printf '\n  %s (%s)\n      for: %s\n      run: %s\n' "$1" "$2" "$3" "$4"
}

# Human-facing report of what is missing and why it matters. Reports only:
# installing is a decision, and some of these want an interactive setup step.
report_missing_tools() {
  _missing_shown=0
  _each_missing_tool "${1:-all}" _report_missing_tool
  if [ "$_missing_shown" -eq 1 ]; then
    printf '\n  Install them yourself, or hand this list to an agent.\n\n'
  fi
  return 0
}

_print_tool_command() { printf '%s\n' "$4"; }

# Same set, just the commands, for a caller that wants to run them.
missing_tool_commands() { _each_missing_tool "${1:-all}" _print_tool_command; }

# symlink src -> dst, moving a pre-existing real file out of the way once
link() {
  _src="$1"
  _dst="$2"
  mkdir -p "$(dirname "$_dst")"
  if [ -e "$_dst" ] && [ ! -L "$_dst" ]; then
    mv "$_dst" "$_dst.pre-dotfiles"
    echo "backed up $_dst -> $_dst.pre-dotfiles"
  fi
  ln -sfn "$_src" "$_dst"
}

# append a line to a file only if it is not already there
append_once() {
  _line="$1"
  _file="$2"
  touch "$_file"
  grep -qF "$_line" "$_file" || printf '%s\n' "$_line" >> "$_file"
}

# Write a named, marked block into ~/.zshrc, replacing an earlier copy of the
# same block. Content comes from stdin.
#
#   zshrc_block starship << 'EOF'
#   eval "$(starship init zsh)"
#   EOF
#
# Everything outside the markers belongs to the machine and is never touched.
# That is the point: ~/.zshrc accumulates per-environment work over time, so
# what this repo injected has to stay attributable.
zshrc_block() {
  _name="$1"
  _rc="$HOME/.zshrc"
  _begin="# >>> oh_my_dotfiles:$_name >>>"
  _end="# <<< oh_my_dotfiles:$_name <<<"
  _tmp="$_rc.dotfiles-tmp"
  touch "$_rc"

  # drop any previous copy of this block, then any trailing blank lines
  awk -v b="$_begin" -v e="$_end" '
    $0 == b { skip = 1 }
    skip != 1 { lines[++n] = $0 }
    $0 == e { skip = 0 }
    END {
      while (n > 0 && lines[n] == "") n--
      for (i = 1; i <= n; i++) print lines[i]
    }
  ' "$_rc" > "$_tmp"

  {
    printf '\n%s\n' "$_begin"
    cat
    printf '%s\n' "$_end"
  } >> "$_tmp"

  mv "$_tmp" "$_rc"
}

# in-place sed that works with both BSD and GNU sed
sed_inplace() {
  _expr="$1"
  _file="$2"
  sed "$_expr" "$_file" > "$_file.dotfiles-tmp" && mv "$_file.dotfiles-tmp" "$_file"
}
