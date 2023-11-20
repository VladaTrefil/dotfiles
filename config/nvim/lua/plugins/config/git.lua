local M = {}

local load_mappings = require('core.utils').load_mappings

M.lazygit = function()
	vim.g.lazygit_floating_window_winblend = 1
	-- vim.g.lazygit_floating_window_use_plenary = 1

	load_mappings(require('core.mappings').lazygit)
end

M.gitgutter = function()
	vim.cmd([[
    let g:gitgutter_sign_added = '\ +'
    let g:gitgutter_sign_modified = '\ ~'
    let g:gitgutter_sign_removed = '\ -'
    let g:gitgutter_sign_removed_first_line = '\ -'
    let g:gitgutter_sign_removed_above_and_below = '\ -'
    let g:gitgutter_sign_modified_removed = '\ ~'
  ]])
end

M.blamer = function()
	local mappings = require('core.mappings').blamer
	load_mappings(mappings)
end

return M
