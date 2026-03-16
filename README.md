# oh_my_dotfiles

My personal dev environment, version controlled so I stop reconfiguring everything from scratch every time I get a new machine.

If these configs look bad, I'm just not nerdy enough yet.

---

## What's in here

| Tool | Config | What it does |
|------|--------|--------------|
| zsh | `zsh/` | oh-my-zsh + zsh-autosuggestions + zsh-syntax-highlighting |
| Starship | `starship/` | Shell prompt (bracketed segments preset) |
| tmux | `tmux/` | Gruvbox theme, C-a prefix, tpm plugins |
| Neovim | `nvim/` | Minimal config for quick terminal edits (Cursor is primary) |
| Git | `git/` | gitconfig + commit message template |

---

## Install

No root `install.sh` yet — working on it. For now, run each tool's installer individually:

```sh
git clone https://github.com/ckjeter/oh_my_dotfiles ~/.dotfiles

sh ~/.dotfiles/starship/install.sh
sh ~/.dotfiles/tmux/install.sh
sh ~/.dotfiles/nvim/install.sh
sh ~/.dotfiles/git/install.sh
sh ~/.dotfiles/zsh/install.sh
```

> A root `install.sh` that runs all of the above is coming soon.

---

## Cheatsheets

- [Neovim](nvim/CHEATSHEET.md)
- [tmux](tmux/CHEATSHEET.md)
