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

## Nested sessions (local tmux → ssh → remote tmux)

Both machines use the same `C-a` prefix on purpose, so muscle memory carries over.

| Key | Action |
|-----|--------|
| `prefix + <key>` | Acts on the **outer** (local) session |
| `prefix + prefix + <key>` | Acts on the **inner** (remote) session |
| `F12` | Mute the outer session — every key, including a bare prefix, goes to the inner one. Status bar dims |
| `F12` again | Take control back |

> The remote status bar carries a yellow hostname badge on the left, so the
> layer you are typing into is always visible.

---

## Misc

| Key | Action |
|-----|--------|
| `prefix + Tab` | fzf window switcher, MRU-ordered (see below) |
| `prefix + r` | `refresh-client` (redraw) |

### prefix + Tab window switcher

Jumps to any window in any session. Each row shows, instantly:

```
CMU-Logixian:3   kitchen   2h  [main +9]   ✳🌙 Claude Code
```

- **Order** is per-window MRU: how recently you were in each window, so the
  top entry is always the one you just came from, never clumped by session
- **Age** is how long since you last focused that window. A forgotten
  session floats with a large age next to its agent task
- **Git badge** is the branch and changed-file count of the window's active
  pane, answering "which project was this again". Served from a cache and
  refreshed in the background, so a cold first open may lack badges; press
  `ctrl-r` to reload, the next open is always fresh
- **Agent symbols**, one per agent pane: `✳` Claude Code, `🌙` Kimi, `⬡`
  Codex, `🚁` Copilot, `⚡` amp, and so on (table at the top of
  `scripts/tmux-mru.sh`), followed by the first agent's task

The preview pane expands the highlighted window: every agent pane and its
task, all panes with commands and paths, live git status with recent changes,
and past agent sessions for that directory with their `--resume` commands
(needs `lazyagent` + `jq`, section disappears without them).

Backed by `scripts/tmux-mru.sh` (MRU stack via two hooks) and
`scripts/agent-history.sh` (the only file that knows about lazyagent).
Everything renders from one tmux call; slow data is cached, never blocking.
| `prefix + I` | Install plugins (tpm) |
| `prefix + U` | Update plugins (tpm) |
| `prefix + t` | Show clock |
