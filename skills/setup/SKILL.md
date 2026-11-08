---
name: setup
description: Install or remove the shell side of rex-restore-claude, which puts each Rex pane's Claude resume command back on its prompt after a Rex server restart. Use when the user runs /rex-restore-claude:setup, or asks to set up, install, enable, uninstall or remove rex-restore-claude.
---

# rex-restore-claude setup

The plugin's `SessionStart` hook already records `<claude command> --resume <id>`
for Claude sessions in Rex panes. This skill installs the part that lives in the
shell: a zsh snippet that puts the saved command on the prompt when the pane's
shell starts.

1. Run the installer. Pass `--rex` as well if the user wants the Rex palette
   action "Restore Claude Session" (useful on a pane that came back with an empty
   prompt). Pass `--uninstall` instead to remove everything.

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/install.sh" [--rex | --uninstall]
   ```

2. If the user starts Claude through an alias or wrapper (for example
   `claude-yolo`), the resume command should use it. Check with
   `grep -n REX_RESTORE_CLAUDE_CMD ~/.zshrc`; if it is missing, ask which
   command they use and add `export REX_RESTORE_CLAUDE_CMD=<command>` to
   `~/.zshrc`.

3. Tell the user what changed. Shells that are already open don't load the
   snippet until they restart; Claude sessions pick up the plugin hook when they
   next start or resume.

Only zsh is supported. The hook needs `jq`.
