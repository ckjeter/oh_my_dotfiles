ln -s ~/.dotfiles/vim/vim.symlink ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PlugInstall
#python3 ~/.vim/plugged/YouCompleteMe/install.py --all > /dev/null 2>&1

