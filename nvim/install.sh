#vimrc setup
ln -s ~/.dotfiles/nvim/nvim.symlink ~/.vimrc
mkdir -p ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim

#Vundle setup
git clone https://github.com/VundleVim/Vundle.vim.git ~/.config/nvim/bundle/Vundle.vim
# pip install pynvim
nvim +PlugInstall
