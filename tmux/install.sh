#!/bin/sh
ln -s -b ~/.dotfiles/tmux/tmux.symlink ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
