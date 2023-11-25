local M = {}

local load_mappings = require('core.utils').load_mappings
local icons = require('core.icons')

M.lazygit = function()
	vim.g.lazygit_floating_window_winblend = 1
	-- vim.g.lazygit_floating_window_use_plenary = 1

	load_mappings(require('core.mappings').lazygit)
end

M.signs = function()
	local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')

	if not gitsigns_ok then
		vim.notify('gitsigns not found', vim.log.levels.ERROR)
		return
	end

	gitsigns.setup({
		signs = {
			add = { text = icons.PipeDashed },
			change = { text = icons.PipeDashed },
			delete = { text = icons.PipeDashed },
			topdelete = { text = icons.PipeDashed },
			changedelete = { text = icons.PipeDashed },
			untracked = { text = icons.PipeDashed },
		},
		sign_priority = 6,
		attach_to_untracked = true,
	})
end

M.blamer = function()
	local mappings = require('core.mappings').blamer
	load_mappings(mappings)
end

return M
