#!/usr/bin/env bash
# Install the shell side of rex-restore-claude (the Claude hook ships with the plugin).
#   install.sh            copy the zsh snippet and source it from ~/.zshrc
#   install.sh --rex      also load the "Restore Claude Session" action in Rex's init.lua
#   install.sh --uninstall  remove both lines and the installed copies
# Files are copied to a stable location because the plugin's own directory
# changes with each version. Re-running is safe and refreshes the copies.
set -euo pipefail
src=$(cd "$(dirname "$0")/.." && pwd)
share="${XDG_DATA_HOME:-$HOME/.local/share}/rex-restore-claude"
zshrc="${ZDOTDIR:-$HOME}/.zshrc"
rexinit="${REX_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/rex/init.lua}"
marker="# rex-restore-claude"
match="rex-restore-claude/rex-restore-claude.zsh"  # identifies our source line
zsh_line="[[ -r \"$share/rex-restore-claude.zsh\" ]] && source \"$share/rex-restore-claude.zsh\"  $marker"
lua_line="dofile(\"$share/restore.lua\")  -- rex-restore-claude"

drop_line() {  # drop_line FILE PATTERN: remove lines containing PATTERN
  [ -f "$1" ] || return 0
  grep -vF -- "$2" "$1" > "$1.rex-restore-claude.tmp" || true
  cat "$1.rex-restore-claude.tmp" > "$1" && rm -f "$1.rex-restore-claude.tmp"
}

case "${1:-}" in
  --uninstall)
    drop_line "$zshrc" "$match"
    drop_line "$rexinit" "-- rex-restore-claude"
    rm -rf "$share"
    command -v rex >/dev/null && rex config reload >/dev/null 2>&1 || true
    echo "rex-restore-claude: removed from $zshrc and $rexinit. Saved commands stay in ${XDG_STATE_HOME:-$HOME/.local/state}/rex-lastcmd."
    exit 0 ;;
  ""|--rex) ;;
  *) echo "usage: $0 [--rex|--uninstall]" >&2; exit 2 ;;
esac

mkdir -p "$share"
# Saved commands are private to the user.
state="${XDG_STATE_HOME:-$HOME/.local/state}/rex-lastcmd"
if [ -d "$state" ]; then chmod 700 "$state"; find "$state" -type f -exec chmod 600 {} +; fi
cp "$src/shell/rex-restore-claude.zsh" "$src/rex/restore.lua" "$share/"
if grep -qF "$match" "$zshrc" 2>/dev/null; then
  echo "rex-restore-claude: $zshrc already sources it; refreshed $share"
else
  printf '\n%s\n' "$zsh_line" >> "$zshrc"
  echo "rex-restore-claude: added to $zshrc (new shells pick it up)"
fi

if [ "${1:-}" = "--rex" ]; then
  mkdir -p "$(dirname "$rexinit")"
  if grep -qF -- "-- rex-restore-claude" "$rexinit" 2>/dev/null; then
    echo "rex-restore-claude: $rexinit already loads the action"
  else
    printf '\n%s\n' "$lua_line" >> "$rexinit"
    echo "rex-restore-claude: added the Restore Claude Session action to $rexinit"
  fi
  command -v rex >/dev/null && rex config reload >/dev/null 2>&1 || true
fi
