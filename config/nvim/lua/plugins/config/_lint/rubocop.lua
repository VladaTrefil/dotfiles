local severity_map = {
	['fatal'] = vim.diagnostic.severity.ERROR,
	['error'] = vim.diagnostic.severity.ERROR,
	['warning'] = vim.diagnostic.severity.WARN,
	['convention'] = vim.diagnostic.severity.HINT,
	['refactor'] = vim.diagnostic.severity.INFO,
	['info'] = vim.diagnostic.severity.INFO,
}

local function server_argument()
	local output = vim.fn.system('bundle exec rubocop --server --version')

	if not output:match('--server') then
		return '--server'
	end
end

local function config_path()
	if vim.fn.filereadable(vim.fn.getcwd() .. '/.rubocop.yml') then
		return vim.fn.getcwd() .. '/.rubocop.yml'
	else
		return vim.fn.expand('$XDG_CONFIG_HOME/rubocop/rubocop.yml')
	end
end

-- TODO: disable diagnostics underline in multiline diagnostics
return {
	cmd = 'bundle',
	stdin = true,
	args = {
		'exec',
		'rubocop',
		'--force-exclusion',
		'--config',
		vim.fn.expand('$XDG_CONFIG_HOME/rubocop/rubocop.yml'),
		-- config_path(),
		server_argument(),
		'--format',
		'json',
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
