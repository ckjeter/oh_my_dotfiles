ln -s -b ~/.dotfiles/vim/vim.symlink ~/.vimrc
vim +PlugInstall
python3 ~/.vim/plugged/YouCompleteMe/install.py --all > /dev/null 2>&1

