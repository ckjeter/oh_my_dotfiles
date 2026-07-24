# Dotfiles Modernization Plan

## Completed
- [x] Add Starship config + install script
- [x] Fix nvim/install.sh (Vundle → vim-plug)
- [x] Update README
- [x] Add Ghostty config + install script
- [x] Root `install.sh` orchestrating every sub-installer, idempotent, OS-aware
- [x] `scripts/lib.sh` shared helpers (package manager detection, safe symlink,
      append-once, portable sed)
- [x] Linux support: the same tracked configs run on Ubuntu servers
- [x] CI runs a full bootstrap in a bare `ubuntu:24.04` container
- [x] Stop installing tools. `scripts/requirements.tsv` says what is needed and
      why, the scripts report, the operator decides
- [x] `scripts/doctor.sh`, read-only state of any machine
- [x] Marked `# >>> oh_my_dotfiles:<name> >>>` blocks so injected zshrc lines
      stay attributable
- [x] `hosts/` for per-machine shell config and the written record

## 1. Refactor zsh setup (partly done)

`zsh/install.sh` is now idempotent and never replaces `~/.zshrc`. It appends an
oh-my-zsh block only when one is missing, and each tool's installer appends its
own init line.

Current state: `~/.zshrc` is untracked and mixes safe config with API keys and
tool inits dumped over time. Still open:

- [ ] `~/.zshrc.local` — untracked, for API keys + third-party injected blocks (conda, etc.)
- [ ] Decide whether a tracked `zsh/zshrc.symlink` base is worth it, given the
      installers already inject what each tool needs

Needs a careful audit of the current `~/.zshrc` before implementing.

## 2. Server environment

- [ ] Re-bootstrap `kuan-dev-1` from a clean slate to prove the git path end to end
- [ ] Decide whether `node` and `build-essential` belong on the dev box, which
      would turn coc, copilot, and treesitter parsers back on there
- [ ] Write `hosts/kuan-dev-1.md` once that box settles, recording what it has
      beyond the shared baseline and why

## Future Enhancements
- [ ] tmux: add `tmux-thumbs` for hint-based text selection (URLs, file paths, git hashes)

## Tab switcher roadmap (scripts/tmux-mru.sh)

Working today: instant per-window MRU list, last-focus age, git badge
(cached, background refresh), per-platform agent symbols with the running
task, preview with live git and lazyagent session history.

- [ ] actions from the popup: kill window, new window in the highlighted
      repo, resume a historical agent session in a new pane (fzf --expect)
- [ ] live updates while the popup is open (fzf --listen fed from tmux hooks)
- [ ] consider extracting as a tpm plugin once daily use proves the design
      (a `.tmux` entry script that sets the hooks and binding is all it takes)

## Out of Scope
- No nvim → Lua migration
- No stow (manual symlinks are fine at this scale)
- No oh-my-zsh removal (it works fine)
- No avante.nvim — would replace Claude Code CLI with a weaker in-editor API integration; Claude Code + diffview is the preferred workflow
