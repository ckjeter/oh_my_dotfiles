# oh_my_dotfiles

Personal portable dev environment. Managed as a side project.

## Conventions
- `*.symlink` files → symlinked to `~/` (e.g. `tmux.symlink` → `~/.tmux.conf`)
- `*.toml.symlink` / `*.config.symlink` → symlinked to `~/.config/`
- git is the exception. `~/.gitconfig` stays a local file and pulls in
  `git/gitconfig.shared` with `include.path`, because git writes to
  `~/.gitconfig` at runtime and a symlink would commit machine state back here
- `~/.zshrc` belongs to the machine, not to this repo. It accumulates whatever
  that environment ends up needing. Anything an installer injects goes inside a
  marked `# >>> oh_my_dotfiles:<name> >>>` block via `zshrc_block`, so what the
  repo put there stays attributable and replaceable. The oh-my-zsh bootstrap is
  deliberately outside any block: the plugin list is yours to edit
- The goal is a familiar starting point on a new machine, not a clone of an old
  one. Prefer reporting what is missing over silently reproducing local state
- Each tool has its own folder with an `install.sh`
- Root `install.sh` (to be created) orchestrates all sub-installers
- Configs run on the macOS laptop and on Linux dev servers (Oracle `kuan-dev-1`).
  Keep one tracked file per tool and guard platform-specific bits inside it
  (`if-shell` for tmux, `has('nvim')` / `executable()` for the vimrc) rather
  than forking per host

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
| git/ | aliases and shared settings only. Identity, credentials, and LFS filters stay machine-local |
| hosts/ | per-machine shell config and written record, named by short hostname |
| scripts/ | shared install helpers, `doctor.sh`, `requirements.tsv`, terminfo push, tmux session ordering |
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
| `lint` | `ubuntu-latest` | bash syntax across all `*.sh`, plus POSIX `sh -n` on the installers since that is how they run |
| `install` | `macos-latest` + `ubuntu-latest` | Root install with `DOTFILES_SKIP_PKG` / `DOTFILES_SKIP_PLUGINS`, symlinks exist, second run stays idempotent, no duplicate `~/.zshrc` lines |
| `bootstrap` | bare `ubuntu:24.04` container | Real install with no skips: tools land, tmux config parses and picks the Linux branch, nvim starts silently, plain vim without `+lua` still exits 0 |

The container job is the portability guarantee. If a change breaks a fresh
Linux box, it fails there.

### What is NOT tested (by design)

- Neovim plugin rendering — requires a display
- Homebrew installs on macOS — too slow, so the macOS job runs with `DOTFILES_SKIP_PKG=1`
- Interactive bits — `chsh` is skipped when stdin is not a tty
- Terminfo push — needs both a laptop terminal and a remote host

### Running tests locally before pushing

```bash
# syntax
find . -name "*.sh" | xargs -I{} bash -n {}
find . -name "install.sh" | xargs -I{} sh -n {}

# full clean-room bootstrap, needs docker
docker run --rm -v "$PWD:/root/.dotfiles:ro" ubuntu:24.04 sh -c \
  'apt-get update -qq && apt-get install -y -qq git curl ca-certificates && sh /root/.dotfiles/install.sh'
```

### Adding tests for a new tool

Add the tool to the loop in the root `install.sh`, then a verify step in
`.github/workflows/test.yml`:

```yaml
- name: Verify <tool> symlinks
  run: test -L ~/<expected-symlink> || (echo "symlink missing" && exit 1)
```

## Install script rules

- POSIX `sh`, no bashisms. They are invoked as `sh <path>`
- Source `scripts/lib.sh` for `have`, `os_family`, `pkg_install`, `as_root`,
  `link`, `append_once`, `sed_inplace`
- Idempotent. Re-running must not duplicate lines or re-download anything
- Never overwrite `~/.zshrc`. It is untracked and holds secrets, so append only
- Honor `DOTFILES_SKIP_PKG` and `DOTFILES_SKIP_PLUGINS`

## Symlink Audit
```bash
ls -la ~ | grep dotfiles
ls -la ~/.config | grep dotfiles
```
