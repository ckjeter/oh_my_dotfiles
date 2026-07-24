#!/bin/sh
# ~/.gitconfig is machine-local on purpose. git writes to it at runtime, so
# symlinking it into the repo means `git lfs install` and friends commit
# machine state back here. Instead, include the shared settings from it.
set -e
. "$(dirname "$0")/../scripts/lib.sh"

# keys that belong to this machine, not to the repo
LOCAL_KEYS='user.name user.email user.signingkey github.user commit.gpgsign
credential.helper filter.lfs.clean filter.lfs.smudge filter.lfs.process
filter.lfs.required'

# migrate an older install where ~/.gitconfig was a symlink into the repo
if [ -L "$HOME/.gitconfig" ]; then
  echo "migrating ~/.gitconfig from a repo symlink to a local file"
  saved=$(mktemp)
  for key in $LOCAL_KEYS; do
    value=$(git config --global --get "$key" 2>/dev/null) || value=''
    [ -n "$value" ] && printf '%s\t%s\n' "$key" "$value" >> "$saved"
  done
  rm "$HOME/.gitconfig"
  while IFS="$(printf '\t')" read -r key value; do
    [ -n "$key" ] && git config --global "$key" "$value"
  done < "$saved"
  rm -f "$saved"
fi

git config --global include.path "$DOTFILES/git/gitconfig.shared"
git config --global commit.template "$DOTFILES/git/gitmessage"

# required for the GPG passphrase prompt in interactive shells
zshrc_block git << 'EOF'
export GPG_TTY=$(tty)
EOF

if [ -z "$(git config --global --get user.email)" ]; then
  echo
  echo "this machine has no git identity yet. Set one before committing:"
  echo "  git config --global user.name  'Your Name'"
  echo "  git config --global user.email 'you@example.com'"
fi
