# primary editor is Cursor — this config is for quick terminal edits only

# symlink setup
ln -sf ~/.dotfiles/nvim/nvim.symlink ~/.vimrc
mkdir -p ~/.config/nvim
ln -sf ~/.vimrc ~/.config/nvim/init.vim

# vim-plug install
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install plugins (skipped if nvim is not available, e.g. CI)
if command -v nvim > /dev/null 2>&1; then
  nvim +PlugInstall +qall
else
  echo "nvim not found — skipping plugin install. Run ':PlugInstall' manually after installing nvim."
fi
