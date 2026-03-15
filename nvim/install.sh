# primary editor is Cursor — this config is for quick terminal edits only

# symlink setup
ln -sf ~/.dotfiles/nvim/nvim.symlink ~/.vimrc
mkdir -p ~/.config/nvim
ln -sf ~/.vimrc ~/.config/nvim/init.vim

# vim-plug install
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# pip install pynvim
nvim +PlugInstall +qall
