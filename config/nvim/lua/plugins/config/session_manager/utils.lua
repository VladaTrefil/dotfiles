local sessions_mngr_ok, _ = pcall(require, 'session_manager')

if not sessions_mngr_ok then
	return false
end

local M = {}

local utils = require('core.utils')
local sm_utils = require('session_manager.utils')
local sm_config = require('session_manager.config')

M.get_current_dir_session_name = function()
	local cwd = vim.loop.cwd()

	if cwd then
		local session = sm_config.dir_to_session_filename(cwd)

		if session:exists() then
			return session:_fs_filename()
		end
	end
end

M.restore_session = function(session_name)
	if not session_name then
		session_name = M.get_current_dir_session_name()
	end

	if session_name then
		sm_utils.load_session(session_name)

		utils.notify('Restored default session', vim.log.levels.INFO, { title = 'Session manager' })
	else
		utils.notify(
			'No session for this directory',
			vim.log.levels.WARN,
			{ title = 'Session manager', timeout = 2000 }
		)
	end
end

return M
