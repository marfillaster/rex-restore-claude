-- rex-restore-claude: a Rex action that types the focused pane's saved Claude resume command
-- onto its prompt, without running it. Use it on a pane whose shell was already
-- running when the command was saved. Load it from init.lua with dofile().
local dir = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/rex-lastcmd/"

rex.action{
  name = "restore_claude_session",
  title = "Restore Claude Session",
  description = "Type this pane's saved `claude --resume` command onto its prompt without running it.",
  category = "Pane",
  keywords = "rex-restore-claude claude resume session conversation",
  run = function(ctx)
    local id = ctx.block_id and ctx.block_id:gsub("^block:", "")
    if not id or not id:match("^[%w%-]+$") then return { restored = false, reason = "no block" } end
    local f = io.open(dir .. id, "r")
    if not f then return { restored = false, reason = "nothing saved" } end
    local cmd = f:read("*a"):gsub("\n+$", "")
    f:close()
    if cmd == "" then return { restored = false, reason = "nothing saved" } end
    -- Text is written as typed keys: a newline, Ctrl-O or an escape sequence can run
    -- the line or trigger a key binding, so refuse any control character.
    if cmd:find("%c") then return { restored = false, reason = "control character in command" } end
    local _, err = rex.block.call("com.superlogical.terminal", "write",
      { block_id = ctx.block_id, data = cmd })
    if err then error(err) end
    return { restored = true, command = cmd }
  end,
}
