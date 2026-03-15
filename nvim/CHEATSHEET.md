# Neovim Cheatsheet

Personal reference for quick terminal edits. Leader key: `\` (backslash).

---

## Pane / Window Navigation (vim-tmux-navigator)

Unified navigation across Neovim splits and tmux panes — no prefix needed:

| Key | Action |
|-----|--------|
| `C-h` | Move left |
| `C-j` | Move down |
| `C-k` | Move up |
| `C-l` | Move right |

---

## File Navigation

| Key | Action |
|-----|--------|
| `\f` | Toggle NERDTree |
| `<C-P>` | Fuzzy find files (fzf) |
| `<C-e>` | Switch buffers (fzf) |
| `\p` | Live grep (ripgrep via fzf) |

---

## Git

| Key / Command | Action |
|---------------|--------|
| `\dv` | Open diffview (all unstaged changes) |
| `\dc` | Close diffview |
| `\dh` | File history for current file |
| `:Git` | Fugitive git status |
| `:Git log` | Git log |
| `:Git blame` | Git blame (full) |

> Inline blame is always on via `blamer.nvim`. Toggle with `:BlamerToggle`.

---

## Code Navigation (coc.nvim)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `\rn` | Rename symbol |
| `[g` / `]g` | Previous / next diagnostic |

---

## Completion & Copilot

| Key | Context | Action |
|-----|---------|--------|
| `<Tab>` | Insert mode | Accept Copilot suggestion |
| `<S-Tab>` | Insert mode (popup visible) | Previous completion item |
| `<S-Tab>` | Insert mode (no popup) | Delete previous word |

---

## Bookmarks (vim-bookmarks)

| Key | Action |
|-----|--------|
| `mm` | Toggle bookmark on current line |
| `mi` | Add annotation to bookmark |
| `mn` / `mp` | Next / previous bookmark |
| `ma` | Show all bookmarks |
| `mc` | Clear bookmarks in file |
| `mx` | Clear all bookmarks |

---

## Markdown (vim-markdown)

| Key / Command | Action |
|---------------|--------|
| `]]` / `[[` | Jump to next / previous header |
| `zo` / `zc` | Open / close fold |
| `zR` / `zM` | Open all / close all folds |
| `ge` | Follow link under cursor |

> Spell check, concealing, and header folding are auto-enabled in `.md` files.

---

## Editing

| Key | Action |
|-----|--------|
| `d` | Delete to black hole (no yank) |
| `cs"'` | Change surrounding `"` to `'` (vim-surround) |
| `ds"` | Delete surrounding `"` |
| `ysiw"` | Wrap word in `"` |

---

## Branch Checkout (fzf)

```
git coi
```
Interactive fuzzy branch switcher with diff preview.
