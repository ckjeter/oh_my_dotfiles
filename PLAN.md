# Dotfiles Modernization Plan

## 1. Add Starship Config
- [ ] Create `starship/` folder
- [ ] Copy `~/.config/starship.toml` → `starship/starship.toml.symlink`
- [ ] Create `starship/install.sh`:
  ```sh
  #!/bin/sh
  brew install starship
  mkdir -p ~/.config
  ln -sf ~/.dotfiles/starship/starship.toml.symlink ~/.config/starship.toml
  ```

## 2. Add Ghostty Config
- [ ] Create `ghostty/` folder
- [ ] Create `ghostty/config.symlink` with minimal settings (font, theme, shell)
- [ ] Create `ghostty/install.sh`:
  ```sh
  #!/bin/sh
  mkdir -p ~/.config/ghostty
  ln -sf ~/.dotfiles/ghostty/config.symlink ~/.config/ghostty/config
  ```

## 3. Fix zsh/install.sh
- [ ] Remove Powerlevel10k install (no longer used)
- [ ] Add Starship install step (defer to starship/install.sh or inline)
- [ ] Keep: oh-my-zsh + zsh-autosuggestions + zsh-syntax-highlighting

## 4. Fix nvim/install.sh
- [x] Remove Vundle clone (config uses vim-plug, not Vundle)
- [x] Add vim-plug install:
  ```sh
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  ```
- [x] Keep symlink setup: `~/.vimrc` → `nvim.symlink`, `~/.config/nvim/init.vim` → `~/.vimrc`
- [x] Add comment: "primary editor is Cursor — this config is for quick terminal edits only"

## 5. Create Root install.sh
- [ ] Create `~/.dotfiles/install.sh` that calls each sub-installer:
  ```sh
  #!/bin/sh
  sh git/install.sh
  sh zsh/install.sh
  sh starship/install.sh
  sh tmux/install.sh
  sh nvim/install.sh
  sh ghostty/install.sh
  ```
- [ ] Add guard: check if symlink already exists before creating (avoid re-run errors)

## 6. Fix gitignore Symlink Username
- [ ] Re-run `git/install.sh` or manually fix:
  ```sh
  rm ~/.gitignore
  ln -s ~/.dotfiles/git/gitignore.symlink ~/.gitignore
  ```

## 7. Update README.md
- [ ] Fix typo ("reporesents")
- [ ] Update toolchain (Starship, Ghostty, Cursor)
- [ ] Point to root `install.sh`

## Out of Scope
- No nvim → Lua migration (Cursor is primary editor)
- No .zshrc tracking in dotfiles (contains API keys)
- No stow (manual symlinks are fine at this scale)
- No oh-my-zsh removal (it works fine)
