local M = {}

-- Get a reference to the original signs handler
local orig_signs_handler = vim.diagnostic.handlers.signs

-- Get the most severe diagnostic per line
-- @param diagnostics - table of vim.diagnostics
-- @return table of vim.diagnostics
local find_most_severe = function(diagnostics)
	local max_severity_per_line = {}
	for _, d in pairs(diagnostics) do
		local m = max_severity_per_line[d.lnum]
		if not m or d.severity < m.severity then
			max_severity_per_line[d.lnum] = d
		end
	end

	return vim.tbl_values(max_severity_per_line)
end

-- Register a custom signs handler for diagnostics
M.register = function()
	-- Override the built-in signs handler
	vim.diagnostic.handlers.signs = {
		show = function(namespace, bufnr, diagnostics, opts)
			local most_severe = find_most_severe(diagnostics)
			orig_signs_handler.show(namespace, bufnr, most_severe, opts)
		end,
		hide = function(namespace, bufnr)
			orig_signs_handler.hide(namespace, bufnr)
		end,
	}
end

return M
