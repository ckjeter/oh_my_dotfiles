# kuan-dev-1 (Oracle A1, Ubuntu 24.04 arm64)

Remote dev box, reached over SSH from the laptop.

## Go navigation in Neovim

- System Go is `/usr/bin/go` 1.22.2. Projects use Go 1.27, which
  `GOTOOLCHAIN=auto` fetches from a project's `go.mod`/`go.work`.
- `gopls` v0.23.0 in `~/.local/bin`, built with Go 1.27.0. That build setting
  does not change the default `go` command. Installed 2026-09-07.
- Write full versions like `go 1.27.0` in `go.mod`/`go.work`. A bare `go 1.27`
  makes the 1.22 launcher look for a nonexistent `go1.27` toolchain and the
  workspace fails to load.
- Verified on throwaway 1.22 and 1.27.0 modules: cross-package `gd`, `Ctrl-o`,
  `gr`, `K`, and a config reload without a duplicate server. 1.22 works but is
  outside gopls's official support window.
- An older v0.17.1 build left its Go 1.23.12 toolchain in the module cache.

Reinstall:

```sh
GOBIN="$HOME/.local/bin" GOTOOLCHAIN=go1.27.0 go install golang.org/x/tools/gopls@v0.23.0
```

## tmux

- System tmux is 3.4. agent-deck wants 3.5+ for csi-u extended keys
  (Shift+Enter in Claude Code). `scripts/doctor.sh` prints the source build.
