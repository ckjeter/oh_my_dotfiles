# hosts/

Per-machine additions, tracked. This is where a machine gets to be different
without the shared configs forking.

Two kinds of file, both named after the machine's short hostname:

| File | What it is |
|------|-----------|
| `<hostname>.zsh` | Sourced at the end of `~/.zshrc`, from the `oh_my_dotfiles:host` block. Aliases, PATH entries, env vars that only make sense on that box |
| `<hostname>.md` | The written record: what else is installed on this machine, why, and anything an agent or a future you would otherwise have to rediscover |

Neither is created for you. A machine with nothing special needs neither.

## Why a record file

The shared configs answer "what does every machine of mine look like". They
cannot answer "why does this box have `oci-cli` and a systemd timer on it".
Without somewhere to write that down, the answer lives in a chat log and is
gone next week.

Keep it short and factual. What was installed, what it is for, and anything
non-obvious about how it was set up. If something turns out to belong on every
machine, promote it: move the tool into `scripts/requirements.tsv` and the
config into the shared file.

## Example

`hosts/kuan-dev-1.md`

```markdown
# kuan-dev-1 (Oracle A1, Ubuntu 24.04 arm64)

Remote dev box, reached over SSH from the laptop.

- docker: runs throwaway containers for testing installers
- no node, no build-essential: coc, copilot, and treesitter parsers stay off
  here on purpose, this box is for editing and shell work
```

`hosts/kuan-dev-1.zsh`

```zsh
alias dc='docker compose'
export EDITOR=nvim
```
