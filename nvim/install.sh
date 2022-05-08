#vimrc setup
ln -s ~/.dotfiles/nvim/vim.symlink ~/.vimrc
mkdir -p ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim

#Vundle setup
git clone https://github.com/VundleVim/Vundle.vim.git ~/.config/nvim/init.vim
pip install pynvim
.~/.config/nvim/bundle/YouCompleteMe/install.py
vim +PlugInstall

