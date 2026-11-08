# rex-restore-claude: when a Rex pane's shell starts (after a Rex server restart),
# put the pane's saved Claude resume command on the prompt, unrun.
#
# The plugin's SessionStart hook writes the saved command; this file only reads it.
# Keyed by $REX_BLOCK, which a pane keeps across restarts. Saved files unused for
# 30 days are pruned.
[[ ${REX_BLOCK#block:} =~ '^[A-Za-z0-9-]+$' ]] || return 0   # also skips outside Rex

() {
  emulate -L zsh
  local dir=${XDG_STATE_HOME:-$HOME/.local/state}/rex-lastcmd
  local file=$dir/${REX_BLOCK#block:}
  [[ -d $dir ]] || return 0
  find $dir -type f -mtime +30 -delete 2>/dev/null
  [[ -s $file ]] && print -z -- "$(<$file)"
}
