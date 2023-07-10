local plenary_present, plenary = pcall(require, 'plenary.path')

if not plenary_present then
  return
end

local session_manager_present, session_manager = pcall(require, 'session_manager')

if not session_manager_present then
  return
end

local mappings = require('core.mappings').session_manager
local utils = require('core.utils')

session_manager.setup({
  -- The directory where the session files will be saved.
  sessions_dir = plenary:new(vim.fn.stdpath('data'), 'sessions'),

  -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
  autoload_mode = require('session_manager.config').AutoloadMode.Disabled,

  -- Automatically save last session on exit and on session switch.
  autosave_last_session = false,

  -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
  max_path_length = 80,
})

utils.load_mappings(mappings)
