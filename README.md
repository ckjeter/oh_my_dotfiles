# oh_my_dotfiles

My personal dev environment, version controlled so I stop reconfiguring everything from scratch every time I get a new machine.

If these configs look bad, I'm just not nerdy enough yet.

---

## What's in here

| Tool | Config | What it does |
|------|--------|--------------|
| zsh | `zsh/` | oh-my-zsh + zsh-autosuggestions + zsh-syntax-highlighting |
| Starship | `starship/` | Shell prompt (bracketed segments preset) |
| tmux | `tmux/` | Catppuccin Mocha, C-a prefix, tpm plugins |
| Neovim | `nvim/` | Minimal config for quick terminal edits |
| Git | `git/` | Aliases and shared settings, included from a local `~/.gitconfig` |
| Ghostty | `ghostty/` | Terminal config, laptop only |

---

## Install

Same two commands on a MacBook and on a bare Ubuntu server. Re-running is safe.

```sh
git clone https://github.com/ckjeter/oh_my_dotfiles ~/.dotfiles
sh ~/.dotfiles/install.sh
```

It symlinks every config, wires up git and zsh, pulls the tmux and Neovim
plugins, and then prints what tools are missing. Individual installers still
work on their own (`sh ~/.dotfiles/tmux/install.sh`).

Set `DOTFILES_SKIP_PLUGINS=1` to skip the tmux and Neovim plugin downloads.

### It does not install tools

Several of them want an interactive step, and changing your shell or reaching
for `sudo` is not something a config script should do behind your back. So the
install reports instead:

```
Missing tools. Nothing in this repo installs them:

  fzf (required)
      for: prefix + Tab window switching in tmux, the git coi alias, and Ctrl-P in nvim
      run: sudo apt install -y fzf
```

`scripts/requirements.tsv` is the list: every tool, whether it is required or
optional, what it is for, and the command per platform. Run the commands
yourself, or hand the list to an agent.

### What the repo owns on a machine

The point is a familiar starting environment, not a copy of another machine.
So the boundary is explicit:

| Path | Owner |
|------|-------|
| `~/.tmux.conf`, `~/.vimrc`, `~/.config/nvim/init.vim`, `~/.config/starship.toml` | Symlinks into the repo. Fully owned |
| `~/.gitconfig` | The machine. The repo only adds an `include.path` to `git/gitconfig.shared` |
| `~/.zshrc` | The machine. The repo owns only what sits inside `# >>> oh_my_dotfiles:<name> >>>` blocks |
| everything else | The machine |

`~/.zshrc` grows over time with whatever that environment ends up needing, so
it is untracked and never replaced. The oh-my-zsh bootstrap is written once and
then left alone, because the plugin list is yours to edit.

### Machines that need to differ

`hosts/<hostname>.zsh` is sourced at the end of `~/.zshrc`, and
`hosts/<hostname>.md` is where that machine's extra tools and their reasons get
written down. Both are tracked, neither is created for you. See
[hosts/README.md](hosts/README.md).

To see where any machine stands, without changing anything:

```sh
sh ~/.dotfiles/scripts/doctor.sh
```

It reports tools and versions, which configs are wired up, which features are
on or off on this box (coc needs `node`, treesitter needs a compiler), how the
clipboard is routed, whether `$TERM` has terminfo, and any lines an older
install left outside the managed blocks.

`~/.gitconfig` is treated the same way: it stays a local file and gets an
`include.path` pointing at `git/gitconfig.shared`, so the repo carries the
aliases while identity, credentials, and whatever `git lfs install` or
`gh auth setup-git` write stay on the machine. A box with no identity yet is
reported, not guessed:

```sh
git config --global user.name  'Kuan Wu'
git config --global user.email 'you@example.com'
```

### Linux servers

The configs detect the platform when they load, so one tracked file per tool
covers both machines: battery drops out of the tmux status bar, a hostname
badge appears instead, yanks reach the laptop clipboard over OSC 52, and
coc/copilot load only when `node` is present. Plain `vim` (built without
`+lua`) stops before the plugin section instead of erroring.

Neovim comes from the upstream tarball rather than apt, whose 0.9 is too old
for the OSC 52 clipboard.

Servers do not ship Ghostty's terminfo, which breaks colors and keys over SSH.
Push it once from the laptop:

```sh
~/.dotfiles/scripts/push-terminfo.sh kuan@<host>
```

---

## Cheatsheets

- [Neovim](nvim/CHEATSHEET.md)
- [tmux](tmux/CHEATSHEET.md)
