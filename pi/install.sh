#!/bin/sh
# Link the global Pi footer extension. Pi's settings and credentials stay local.
set -e
. "$(dirname "$0")/../scripts/lib.sh"

link "$DOTFILES/pi/statusline.ts" "$HOME/.pi/agent/extensions/statusline.ts"
echo "Pi statusline -> $DOTFILES/pi/statusline.ts"
have pi || echo "pi is not installed, its statusline is ready for when it is"
