-- Telescope Settings:
---------------------------------------------------------------

local M = {}

local telescope = require('telescope')
local action_state = require('telescope.actions.state')
local action_utils = require('telescope.actions.utils')
local actions = require('telescope.actions')

M.create_autocmds = function()
	-- Set telescope previewer buffer local options
	vim.api.nvim_create_autocmd('User', {
		pattern = 'TelescopePreviewerLoaded',
		callback = function(args)
			vim.opt_local.wrap = true
			vim.opt_local.list = true
			vim.opt_local.tabstop = 2
			vim.opt_local.shiftwidth = 2
			vim.opt_local.number = true

			-- if action_state.get_current_picker(args.bufnr) then
			-- 	vim.opt_local.number = true
			-- end
		end,
	})

	-- Prevent telescope from opening files in insert mode
	-- See: https://github.com/nvim-telescope/telescope.nvim/issues/2027
	vim.api.nvim_create_autocmd('WinLeave', {
		callback = function()
			if vim.bo.ft == 'TelescopePrompt' and vim.fn.mode() == 'i' then
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes('<Esc>', true, false, true),
					'i',
					false
				)
			end
		end,
	})
end

M.load_extension = function(name)
	telescope.load_extension(name)
end

-- Switch to window with buffer if exists or do default select action
M.select_buffer = function(prompt_bufnr)
	local entry = action_state.get_selected_entry()
	local winid = vim.fn.win_findbuf(entry.bufnr)[1]

	if winid then
		vim.fn.win_gotoid(winid)
	else
		actions.select_default(prompt_bufnr)
	end
end

-- local function select_file_entry(prompt_bufnr)
--   local picker = action_state.get_current_picker(prompt_bufnr)
--   local selections = picker:get_multi_selection()mappmapp
--
--   if #selections > 1 then
--     for i, entry in ipairs(selections) do
--       print(i)
--       if i == 1 then
--         vim.cmd.tabnew(entry.value)
--       else
--         vim.cmd.vsplit(entry.value)
--       end
--     end
--
--     vim.cmd('stopinsert')
--   else
--     actions.select_default(prompt_bufnr)
--   end
-- end
return M
