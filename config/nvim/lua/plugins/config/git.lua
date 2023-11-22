local M = {}

local load_mappings = require('core.utils').load_mappings
local icons = require('core.icons')

M.lazygit = function()
	vim.g.lazygit_floating_window_winblend = 1
	-- vim.g.lazygit_floating_window_use_plenary = 1

	load_mappings(require('core.mappings').lazygit)
end

M.gitgutter = function()
	vim.g.gitgutter_sign_added = icons.Plus:gsub('%s', '')
	vim.g.gitgutter_sign_modified = icons.Change:gsub('%s', '')
	vim.g.gitgutter_sign_removed = icons.Minus:gsub('%s', '')
	vim.g.gitgutter_sign_removed_first_line = '‾ '
	vim.g.gitgutter_sign_removed_above_and_below = '_¯'
	vim.g.gitgutter_sign_modified_removed = '~_'

	vim.g.gitgutter_sign_priority = 5
	vim.g.gitgutter_sign_allow_clobber = 1
end

M.blamer = function()
	local mappings = require('core.mappings').blamer
	load_mappings(mappings)
end

return M
