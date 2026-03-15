# oh_my_dotfiles

Personal portable dev environment. Managed as a side project.

## Conventions
- `*.symlink` files → symlinked to `~/` (e.g. `tmux.symlink` → `~/.tmux.conf`)
- `*.toml.symlink` / `*.config.symlink` → symlinked to `~/.config/`
- Each tool has its own folder with an `install.sh`
- Root `install.sh` (to be created) orchestrates all sub-installers

## Current Toolchain
| Tool | Status |
|------|--------|
| Shell | zsh + oh-my-zsh + Starship prompt |
| Terminal | Ghostty (migrated from iTerm2) |
| tmux | tpm plugins, Gruvbox theme, C-a prefix |
| Editor | Cursor (primary), Neovim (quick terminal edits only) |
| Vim keybindings | Used in Cursor via plugin |
| Python | pyenv |
| Node | nvm |
| Java | jenv |
| Packages | brew (arm), brew86 (x86) |

## Tracked Configs
| Folder | What it manages |
|--------|----------------|
| zsh/ | oh-my-zsh setup + plugins |
| tmux/ | tmux.conf + tpm |
| nvim/ | vimrc (minimal, quick edits) |
| git/ | gitconfig only (gitignore is project-specific, not tracked) |
| starship/ | starship.toml |
| ghostty/ | ghostty terminal config |
| scripts/ | tmux session ordering |

## Git Conventions

### Branching
| Branch | Purpose |
|--------|---------|
| `main` | Stable, always working |
| `feat/<scope>` | New config or plugin (e.g. `feat/nvim-diffview`) |
| `fix/<scope>` | Bug fix (e.g. `fix/gitignore-symlink`) |
| `chore/<scope>` | Maintenance, cleanup (e.g. `chore/nvim-plugin-audit`) |

- Branch from `main`, merge back to `main` via PR or direct push for solo work
- Delete branch after merge

### Commit Message
Format: `<type>(<scope>): <summary>`

- **type**: `feat` | `fix` | `chore` | `refactor` | `docs`
- **scope**: `nvim` | `tmux` | `zsh` | `git` | `ghostty` | `starship` | `scripts`
- Template auto-loads via `git/gitmessage` — runs on every `git commit`

## Known Issues
- No root `install.sh` yet — see PLAN.md
- nvim plugins not yet cleaned up on host machine — run `:PlugClean` then `:PlugInstall`

## Testing Strategy

Changes are validated via GitHub Actions on every PR (free for public repos).

### What is tested

| Job | Runner | Checks |
|-----|--------|--------|
| `lint` | `ubuntu-latest` | Shell syntax errors in all `install.sh` files |
| `install` | `macos-latest` | Install scripts run without error + symlinks are created |

### What is NOT tested (by design)

- Neovim plugin rendering — requires a display
- Neovim `:PlugInstall` — skipped on CI if nvim not installed; install scripts guard with `command -v nvim`
- Git config — `git/install.sh` has interactive prompts (author name/email); not CI-testable
- Homebrew package installs — too slow and environment-dependent
- Shell behavior (zsh config, aliases) — depends on existing system state

### Running tests locally before pushing

```bash
# Syntax check all install scripts
find . -name "install.sh" | xargs -I{} bash -n {}
```

### Adding tests for a new tool

When adding a new `<tool>/install.sh`, add a corresponding verify step in `.github/workflows/test.yml`:

```yaml
- name: Run <tool> install
  run: sh .dotfiles/<tool>/install.sh

- name: Verify <tool> symlinks
  run: test -L ~/<expected-symlink> || (echo "symlink missing" && exit 1)
```

## Symlink Audit
```bash
ls -la ~ | grep dotfiles
ls -la ~/.config | grep dotfiles
```
