# tmux Cheatsheet

Prefix key: `C-a` (Ctrl + a)

---

## Sessions

| Key | Action |
|-----|--------|
| `prefix + g` | Switch to another session (sessionist) |
| `prefix + C` | Create new named session (sessionist) |
| `prefix + X` | Kill current session (sessionist) |
| `prefix + S` | Switch to last session (sessionist) |
| `prefix + @` | Promote pane to a new session (sessionist) |
| `prefix + Ctrl-s` | Save session (resurrect) |
| `prefix + Ctrl-r` | Restore session (resurrect) |

> Auto-save runs every 15 min via tmux-continuum. Auto-restore on tmux start.

---

## Windows

| Key | Action |
|-----|--------|
| `prefix + c` | New window |
| `prefix + ,` | Rename window |
| `prefix + &` | Kill window |
| `prefix + n` / `p` | Next / previous window |
| `prefix + 0-9` | Jump to window by number |

---

## Pane / Neovim Navigation (vim-tmux-navigator)

Unified navigation — works across both tmux panes and Neovim splits without prefix:

| Key | Action |
|-----|--------|
| `C-h` | Move left |
| `C-j` | Move down |
| `C-k` | Move up |
| `C-l` | Move right |

---

## Panes

| Key | Action |
|-----|--------|
| `prefix + \|` | Split vertical (pain-control) |
| `prefix + -` | Split horizontal (pain-control) |
| `prefix + h/j/k/l` | Navigate panes (pain-control) |
| `prefix + H/J/K/L` | Resize panes (pain-control) |
| `prefix + z` | Zoom / unzoom current pane |
| `prefix + Z` | Reset all panes to tiled (even) layout |
| `prefix + x` | Kill pane |
| `prefix + q` | Show pane numbers |

---

## Copy Mode (vi)

| Key | Action |
|-----|--------|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy selection and exit |
| `q` | Exit copy mode |
| `o` | Open selected text in default app (tmux-open) |
| `Ctrl-o` | Open selected text in `$EDITOR` (tmux-open) |

---

## Notifications (tmux-notify)

| Key | Action |
|-----|--------|
| `prefix + m` | Monitor current pane — notifies when command finishes |
| `prefix + M` | Cancel monitoring |

> Useful for long-running commands (builds, tests). Switch away and get a macOS notification when done.

---

## Misc

| Key | Action |
|-----|--------|
| `prefix + r` | Reload tmux config (tmux-sensible) |
| `prefix + I` | Install plugins (tpm) |
| `prefix + U` | Update plugins (tpm) |
| `prefix + t` | Show clock |
