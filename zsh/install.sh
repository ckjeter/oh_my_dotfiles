#!/bin/sh
set -e
. "$(dirname "$0")/../scripts/lib.sh"

if ! have zsh; then
  echo "zsh is not installed, skipping. See scripts/requirements.tsv"
  exit 0
fi

# oh-my-zsh. --keep-zshrc matters: ~/.zshrc is untracked and holds machine
# local secrets, so the installer must never replace it.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    git clone --depth=1 "https://github.com/zsh-users/$plugin" "$ZSH_CUSTOM/plugins/$plugin"
  fi
done

# Wire oh-my-zsh into ~/.zshrc, once. Deliberately not a zshrc_block: the
# plugin list and theme are things you edit per environment as that machine
# grows, so this repo hands over a starting point and then stays out of it.
# A zshrc that already sources oh-my-zsh is left alone. A fresh box may have no
# usable zshrc at all, since the installer keeps whatever file it finds and an
# earlier install step may already have created an empty one.
if ! grep -q 'oh-my-zsh.sh' "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" << 'EOF'

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
EOF
fi

if [ -f "$HOME/.zshrc" ]; then
  # enable the two plugins if ~/.zshrc still has the stock line
  if grep -q '^plugins=(git)$' "$HOME/.zshrc"; then
    sed_inplace 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
  fi
  # starship draws the prompt, so oh-my-zsh should not also draw one
  if grep -q '^ZSH_THEME="robbyrussell"$' "$HOME/.zshrc"; then
    sed_inplace 's/^ZSH_THEME="robbyrussell"$/ZSH_THEME=""/' "$HOME/.zshrc"
  fi
fi

# Making zsh the login shell is left to you: chsh is interactive and changing
# your shell is not something a config script should do behind your back.
if [ "$(basename "${SHELL:-}")" != zsh ]; then
  echo "login shell is ${SHELL:-unset}. To switch: chsh -s $(command -v zsh)"
fi
