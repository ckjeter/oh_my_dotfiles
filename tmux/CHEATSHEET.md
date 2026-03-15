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

## Panes

| Key | Action |
|-----|--------|
| `prefix + \|` | Split vertical (pain-control) |
| `prefix + -` | Split horizontal (pain-control) |
| `prefix + h/j/k/l` | Navigate panes (pain-control) |
| `prefix + H/J/K/L` | Resize panes (pain-control) |
| `C-z` | Zoom / unzoom current pane |
| `C-Z` | Reset to even layout |
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

## Misc

| Key | Action |
|-----|--------|
| `prefix + r` | Reload tmux config (tmux-sensible) |
| `prefix + I` | Install plugins (tpm) |
| `prefix + U` | Update plugins (tpm) |
| `prefix + t` | Show clock |
