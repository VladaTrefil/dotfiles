local sessions_mngr_ok, sessions_mngr = pcall(require, 'session_manager')
local plenary_ok, plenary_path = pcall(require, 'plenary.path')

if not sessions_mngr_ok or not plenary_ok then
  return
end

local utils = require('core.utils')

local session_dir = plenary_path:new(vim.fn.stdpath('data'), 'sessions')

if not session_dir:exists() then
  session_dir:mkdir()
end

sessions_mngr.setup({
  sessions_dir = session_dir,
  max_path_length = 80,
  autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
  autosave_last_session = true,
  autosave_ignore_not_normal = true,
  autosave_ignore_dirs = {},
  autosave_ignore_filetypes = {
    'gitcommit',
    'gitrebase',
  },
  autosave_ignore_buftypes = {},
  autosave_only_in_session = false,
})

local session_mappings = require('core.mappings').sessions(sessions_mngr)
utils.load_mappings(session_mappings)
