#!/usr/bin/env bash
# SessionStart hook: inside a Rex pane, record the command that resumes this
# Claude conversation, so the pane's shell can offer it after a Rex restart.
# Runs on startup, /resume, /clear and compaction; each run overwrites the file.
# Never fails the session: any problem exits 0 without writing.
id=${REX_BLOCK#block:}
[[ $id =~ ^[A-Za-z0-9-]+$ ]] || exit 0          # also rejects an unset REX_BLOCK
command -v jq >/dev/null 2>&1 || exit 0
sid=$(jq -r '.session_id // empty' 2>/dev/null) || exit 0
[[ $sid =~ ^[A-Za-z0-9-]+$ ]] || exit 0
umask 077
dir="${XDG_STATE_HOME:-$HOME/.local/state}/rex-lastcmd"
mkdir -p "$dir" 2>/dev/null && [ -O "$dir" ] && chmod 700 "$dir" 2>/dev/null || exit 0
printf '%s --resume %s\n' "${REX_RESTORE_CLAUDE_CMD:-claude}" "$sid" > "$dir/$id" 2>/dev/null
exit 0
