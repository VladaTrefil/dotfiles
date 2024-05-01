local M = {}

local load_mappings = require('core.utils').load_mappings

M.lazygit = function()
	vim.g.lazygit_floating_window_winblend = 1
	-- vim.g.lazygit_floating_window_use_plenary = 1

	load_mappings(require('core.mappings').lazygit)
end

M.blamer = function()
	local mappings = require('core.mappings').blamer
	load_mappings(mappings)
end

return M
