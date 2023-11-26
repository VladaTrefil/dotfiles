local M = {}

local opt = vim.opt
local autocmd = vim.api.nvim_create_autocmd

vim.api.nvim_create_augroup('statuscolumn', { clear = true })
autocmd('FileType', {
	group = 'statuscolumn',
	pattern = 'help',
	callback = function()
		M.hide()
	end,
})

M.hide = function()
	opt.statuscolumn = nil
end

-- Custom status column
M.show = function()
	-- sign column
	opt.statuscolumn = '%s'

	-- fold column
	opt.stc:append('%C')

	-- align to right
	opt.stc:append('%=')

	-- number spacing
	opt.stc:append('%{repeat(" ", v:relnum<2?2-strlen(v:relnum):0)}')

	-- number column
	-- opt.stc:append('%#LineNr#')
	opt.stc:append('%{v:relnum&&&rnu?v:relnum:v:lnum} ')

	-- border column
	opt.stc:append('│ ')
end

return M
