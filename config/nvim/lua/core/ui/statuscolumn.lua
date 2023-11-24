local M = {}

local opt = vim.opt

M.hide_statuscolumn = function()
	opt.statuscolumn = nil
end

M.show_statuscolumn = function()
	-- Custom status column
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
	opt.stc:append('%{v:relnum?v:relnum:v:lnum} ')
	-- border column
	opt.stc:append('│ ')
end

return M
