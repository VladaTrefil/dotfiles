local M = {}

local severity_map = {
	['fatal'] = vim.diagnostic.severity.ERROR,
	['error'] = vim.diagnostic.severity.ERROR,
	['warning'] = vim.diagnostic.severity.WARN,
	['convention'] = vim.diagnostic.severity.HINT,
	['refactor'] = vim.diagnostic.severity.INFO,
	['info'] = vim.diagnostic.severity.INFO,
}

M.shellcheck = {
	args = {
		'--format',
		'json',
		'-',
	},
}

M.stylelint = {
	args = {
		'--config',
		vim.fn.expand('$XDG_CONFIG_HOME/stylelint/stylelintrc.json'),
	},
}

M.codespell = {
	args = {
		'--ignore-words',
		vim.fn.expand('$XDG_CONFIG_HOME/codespell/ignore.txt'),
		'--exclude-file',
		vim.fn.expand('$XDG_CONFIG_HOME/codespell/exclude-file.txt'),
		'--config',
		vim.fn.expand('$XDG_CONFIG_HOME/codespell/codespellrc'),
		'--regex',
		"(?<![a-z])[a-z'`]+|[A-Z][a-z'`]*|[a-z]+'[a-z]*|[a-z]+(?=[_-])|[a-z]+(?=[A-Z])|\\d+",
	},
}

-- TODO: disable diagnostics underline in multiline diagnostics
M.rubocop = {
	cmd = 'bundle',
	stdin = true,
	args = {
		'exec',
		'rubocop',
		'--config',
		vim.fn.expand('$XDG_CONFIG_HOME/rubocop/rubocop.yml'),
		'--format',
		'json',
		'--force-exclusion',
		'--stdin',
		function()
			return vim.fn.expand('%:p')
		end,
	},
	parser = function(output)
		local diagnostics = {}
		local decoded = vim.json.decode(output)

		-- exit if there are no diagnostic messages
		if not decoded or not decoded.files[1] then
			return diagnostics
		end

		local offences = decoded.files[1].offenses

		for _, off in pairs(offences) do
			table.insert(diagnostics, {
				source = 'rubocop',
				lnum = off.location.start_line - 1,
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

return M
