local pattern = '[^:]+:(%d+):(%d+):([^%.]+%.?)%s%(([%a-]+)%)%s?%(?(%a*)%)?'
local groups = { 'lnum', 'col', 'message', 'code', 'severity' }
local severities = {
	[''] = vim.diagnostic.severity.ERROR,
	['warning'] = vim.diagnostic.severity.WARN,
}

return {
	-- parser = require('lint.parser').from_pattern(
	-- 	pattern,
	-- 	groups,
	-- 	severities,
	-- 	{ ['source'] = 'standardjs' },
	-- 	{}
	-- ),
	parser = function(output)
		local diagnostics = {}
		local decoded = vim.json.decode(output)
		print(decoded)

		-- exit if there are no diagnostic messages
		if not decoded or not decoded.files[1] then
			return diagnostics
		end

		local offences = decoded.files[1].offenses

		for _, off in pairs(offences) do
			table.insert(diagnostics, {
				source = 'rubocop',
				lnum = off.location.start_line - 1 or 0,
				col = off.location.start_column - 1,
				end_lnum = off.location.last_line - 1,
				end_col = off.location.last_column,
				severity = severity_map[off.severity],
				message = off.message,
				code = off.cop_name,
			})
		end

		return diagnostics
	end,
}
