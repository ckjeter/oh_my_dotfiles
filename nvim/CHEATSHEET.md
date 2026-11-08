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

> NERDTree shows a git status glyph before each file and folder, VSCode-style,
> so agent-written changes are visible at a glance (untracked, modified,
> staged, dirty subtree). It refreshes on write and when the cursor rests.
> Needs a nerd font, already required by the file icons.

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

## Code Navigation (native LSP)

Neovim's built-in LSP client, no plugin. Requires Neovim 0.11 or newer, which
ships `vim.lsp.config` / `vim.lsp.enable`. Go is the only language wired up so
far, and only when both `go` and `gopls` are on `PATH`. On a machine without
them nothing is configured and these keys keep their built-in vim meaning.

| Key | Action |
|-----|--------|
| `gd` | Go to definition (across files in the workspace) |
| `gr` | List references |
| `K` | Hover documentation / type info |
| `\rn` | Rename symbol |
| `[g` / `]g` | Previous / next diagnostic, with the float |
| `<C-o>` | Jump back to where you came from |
| `<C-i>` | Jump forward again |

> LSP mappings are buffer-local and set when gopls attaches. `<C-o>` and
> `<C-i>` are built-in jump-list navigation and work in every buffer.

### Go

`gopls` starts for `go`, `gomod`, `gowork` and `gotmpl` files. The workspace
root is the first of `go.work`, `go.mod`, `.git` found above the file, so a
multi-module repo with a `go.work` resolves definitions across all of its
modules rather than stopping at the module the file lives in.

Nothing is formatted on save, and no completion plugin is installed. Use
`<C-x><C-o>` for omni completion, `:lua vim.diagnostic.setloclist()` for every
diagnostic in the buffer, and `:checkhealth vim.lsp` to see whether a server
attached.

Install requirements: `go` from brew or apt, and `gopls` via
`GOBIN="$HOME/.local/bin" go install golang.org/x/tools/gopls@latest` with
`$HOME/.local/bin` on `PATH`. gopls officially supports the latest two Go
toolchains at runtime, while projects can declare an older language version.
With `GOTOOLCHAIN=auto`, Go downloads a newer toolchain when required by
`go.mod` or `go.work`. Building gopls with newer Go does not itself upgrade
the `go` command used to analyze a project. See the
[gopls version policy](https://go.dev/gopls/#supported-go-versions).
The installed version and verification results live in `hosts/<host>.md`.
Run `sh scripts/doctor.sh` to check this machine.

Other languages: add another `vim.lsp.config` block in the `lsp` section of
`nvim/nvim.symlink`.

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

> Spell check, concealing, and header folding are auto-enabled in `.md` files. Wavy underlines are spell check, not LSP diagnostics.

| Key | Action |
|-----|--------|
| `zg` | Mark word as correct (add to dictionary) |
| `zw` | Mark word as wrong |
| `z=` | Show spelling suggestions |

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
