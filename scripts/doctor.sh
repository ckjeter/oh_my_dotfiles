#!/bin/sh
# Read-only report of what this machine actually has. Changes nothing.
# Run it first on an unfamiliar box, or after an install to see what landed.
#
#   sh ~/.dotfiles/scripts/doctor.sh
. "$(dirname "$0")/../scripts/lib.sh"

section() { printf '\n== %s\n' "$1"; }
row() { printf '  %-22s %s\n' "$1" "$2"; }

section "machine"
row "os" "$(uname -srm)"
row "login shell" "${SHELL:-unset}"
row "dotfiles" "$DOTFILES"
row "revision" "$(git -C "$DOTFILES" describe --always --dirty 2>/dev/null || echo 'not a git checkout')"
row "TERM" "${TERM:-unset}"
if [ -n "${TERM:-}" ] && infocmp "$TERM" > /dev/null 2>&1; then
  row "terminfo for TERM" "present"
else
  row "terminfo for TERM" "MISSING, run scripts/push-terminfo.sh from the laptop"
fi

section "tools"
# driven by scripts/requirements.tsv so there is one list, not two
while IFS='	' read -r tool need why mac linux; do
  case "$tool" in '' | \#*) continue ;; esac
  if have "$tool"; then
    row "$tool" "$(command -v "$tool")"
  else
    row "$tool" "missing, $need"
  fi
done < "$DOTFILES/scripts/requirements.tsv"
row "vim" "$(command -v vim 2> /dev/null || echo 'missing, optional fallback')"

section "config wiring"
for pair in \
  "$HOME/.tmux.conf:$DOTFILES/tmux/tmux.symlink" \
  "$HOME/.vimrc:$DOTFILES/nvim/nvim.symlink" \
  "$HOME/.config/nvim/init.vim:$HOME/.vimrc" \
  "$HOME/.config/starship.toml:$DOTFILES/starship/starship.toml.symlink"; do
  dst=${pair%%:*}
  want=${pair#*:}
  if [ ! -e "$dst" ]; then
    row "$(basename "$dst")" "missing"
  elif [ "$(readlink "$dst")" = "$want" ]; then
    row "$(basename "$dst")" "linked"
  else
    row "$(basename "$dst")" "NOT ours -> $(readlink "$dst" || echo 'real file')"
  fi
done
row "gitconfig include" "$(git config --global --get include.path || echo 'not set')"
row "git identity" "$(git config --global --get user.email || echo 'not set, commits will fail')"
row "commit template" "$(git config --global --get commit.template || echo 'not set')"

section "features that depend on this machine"
have node && row "coc + copilot" "on, node present" || row "coc + copilot" "off, no node"
{ have cc || have gcc; } && row "treesitter parsers" "on, compiler present" \
  || row "treesitter parsers" "off, no C compiler"
if [ "$(os_family)" = macos ]; then
  row "tmux status bar" "battery segment"
else
  row "tmux status bar" "hostname badge, no battery"
fi
if [ -n "${TMUX:-}" ]; then
  row "nvim clipboard" "via tmux, forwarded by set-clipboard"
elif [ -n "${SSH_TTY:-}" ]; then
  row "nvim clipboard" "OSC 52 to the local machine"
else
  row "nvim clipboard" "local clipboard tool"
fi
if have lazyagent; then
  if msg="$("$DOTFILES/scripts/agent-history.sh" --check 2>/dev/null)"; then
    row "tab-switcher history" "on, lazyagent contract ok"
  else
    row "tab-switcher history" "BROKEN: ${msg:-check failed}, fix scripts/agent-history.sh"
  fi
else
  row "tab-switcher history" "off, no lazyagent (optional)"
fi

section "~/.zshrc"
rc="$HOME/.zshrc"
if [ ! -f "$rc" ]; then
  row "file" "missing"
else
  row "lines" "$(wc -l < "$rc" | tr -d ' ')"
  row "managed blocks" "$(grep -c '^# >>> oh_my_dotfiles:' "$rc" || true)"
  grep '^# >>> oh_my_dotfiles:' "$rc" | sed 's/^/    /' || true
  row "sources oh-my-zsh" "$(grep -q 'oh-my-zsh.sh' "$rc" && echo yes || echo no)"
  # lines this repo used to append before the blocks existed
  stray=$(grep -c 'starship init zsh\|GPG_TTY' "$rc" || true)
  blocked=$(awk '/^# >>> oh_my_dotfiles:/{s=1} s && /starship init zsh|GPG_TTY/{n++} /^# <<< oh_my_dotfiles:/{s=0} END{print n+0}' "$rc")
  if [ "$stray" -gt "$blocked" ]; then
    row "unmanaged leftovers" "$((stray - blocked)) line(s) outside the blocks, from an older install"
  fi
fi

section "this machine's own additions"
host=$(hostname -s)
row "hostname" "$host"
for f in "$DOTFILES/hosts/$host.zsh" "$DOTFILES/hosts/$host.md"; do
  if [ -f "$f" ]; then
    row "hosts/$(basename "$f")" "present"
  else
    row "hosts/$(basename "$f")" "none, see hosts/README.md"
  fi
done

report_missing_tools
