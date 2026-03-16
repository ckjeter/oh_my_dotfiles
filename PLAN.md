# Dotfiles Modernization Plan

## Completed
- [x] Add Starship config + install script
- [x] Fix nvim/install.sh (Vundle → vim-plug)
- [x] Update README

## 1. Add Ghostty Config
- [ ] Create `ghostty/` folder
- [ ] Create `ghostty/config.symlink` with minimal settings (font, theme, shell)
- [ ] Create `ghostty/install.sh`:
  ```sh
  #!/bin/sh
  mkdir -p ~/.config/ghostty
  ln -sf ~/.dotfiles/ghostty/config.symlink ~/.config/ghostty/config
  ```

## 2. Refactor zsh setup (undecided)
Current state: `.zshrc` is untracked — mixes safe config with API keys and tool inits dumped over time.

Proposed approach:
- `zsh/zshrc.symlink` — minimal base (oh-my-zsh, plugins, aliases only)
- Each tool's `install.sh` injects its own init line (nvm, pyenv, jenv, etc.)
- `~/.zshrc.local` — untracked, for API keys + third-party injected blocks (conda, etc.)
- `zsh/install.sh` — install oh-my-zsh + plugins, symlink zshrc, create empty zshrc.local

Not started. Needs careful audit of current `~/.zshrc` before implementing.

## 3. Create Root install.sh
- [ ] Create `~/.dotfiles/install.sh` that calls each sub-installer in order:
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

## Future Enhancements
- [ ] tmux: add `tmux-thumbs` for hint-based text selection (URLs, file paths, git hashes)

## Out of Scope
- No nvim → Lua migration
- No stow (manual symlinks are fine at this scale)
- No oh-my-zsh removal (it works fine)
- No avante.nvim — would replace Claude Code CLI with a weaker in-editor API integration; Claude Code + diffview is the preferred workflow
