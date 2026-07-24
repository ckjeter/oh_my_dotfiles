#!/bin/sh
# Wire this machine up to the tracked config. Safe to re-run.
#
# It does not install tools. Several of them want an interactive setup step,
# so it reports what is missing and what each one is for, and leaves the
# decision to you. See scripts/requirements.tsv.
#
#   sh install.sh
#   DOTFILES_SKIP_PLUGINS=1 sh install.sh   # no tmux/nvim plugin downloads
set -e

DOTFILES="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
export DOTFILES
. "$DOTFILES/scripts/lib.sh"

for tool in git zsh starship tmux nvim hosts; do
  echo "==> $tool"
  sh "$DOTFILES/$tool/install.sh"
done

if [ "$(os_family)" = macos ]; then
  echo "==> ghostty"
  sh "$DOTFILES/ghostty/install.sh"
else
  echo "==> ghostty skipped, the terminal emulator lives on the laptop"
  echo "    from the laptop, teach this host the terminal's terminfo once:"
  echo "    scripts/push-terminfo.sh <user>@$(hostname)"
fi

report_missing_tools
echo "Run 'sh $DOTFILES/scripts/doctor.sh' for the full state of this machine."
