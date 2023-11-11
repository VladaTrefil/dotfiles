local M = {}

M.whichkey_mappings = function(mapping)
	local wk_ok, wk = pcall(require, 'which-key')

	if not wk_ok then
		vim.notify("WhichKey lua package doesn't exist", vim.log.levels.ERROR)
		return
	end

	for mode, mode_mappings in pairs(mapping) do
		wk.register(mode_mappings, { mode = mode })
	end
end

return M
