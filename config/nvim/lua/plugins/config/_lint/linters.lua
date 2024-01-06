local lint_ok, lint = pcall(require, 'lint')

local M = {}
local linters = {}

local severity_map = {
	['fatal'] = vim.diagnostic.severity.ERROR,
	['error'] = vim.diagnostic.severity.ERROR,
	['warning'] = vim.diagnostic.severity.WARN,
	['convention'] = vim.diagnostic.severity.HINT,
	['refactor'] = vim.diagnostic.severity.INFO,
	['info'] = vim.diagnostic.severity.INFO,
}

linters.shellcheck = {
	args = {
		'--format',
		'json',
		'-',
	},
}

linters.stylelint = {
	args = {
		'--config',
		vim.fn.expand('$XDG_CONFIG_HOME/stylelint/stylelintrc.json'),
		'-f',
		'json',
		'--stdin',
		'--stdin-filename',
		function()
			return vim.fn.expand('%:p')
		end,
	},
}

linters.codespell = {
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
linters.rubocop = {
	cmd = 'bundle',
	stdin = true,
	args = {
		'exec',
		'rubocop',
		'--force-exclusion',
		'--config',
		config_path(),
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

local severity_map = {
	['E'] = vim.diagnostic.severity.ERROR,
	['W'] = vim.diagnostic.severity.WARN,
	['I'] = vim.diagnostic.severity.INFO,
}
linters.slimlint = {
	cmd = 'slim-lint',
	stdin = false, -- or false if it doesn't support content input via stdin. In that case the filename is automatically added to the arguments.
	append_fname = false, -- Automatically append the file name to `args` if `stdin = false` (default: true)
	args = {
		'--config',
		vim.fn.getcwd() .. '/.slim-lint.yml',
		function()
			vim.fn.expand('%:p')
		end,
	},
	stream = 'both', -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
	ignore_exitcode = true, -- set this to true if the linter exits with a code != 0 and that's considered normal.
	parser = function(output)
		local file, lnum, severity, message = output:match('^(.+):(%d+) %[(%a)%] (.+)')

		return {
			{
				source = 'slimlint',
				col = 0,
				lnum = tonumber(lnum),
				severity = severity_map[severity],
				message = message,
				file = file,
			},
		}
	end,
}

-- Setup custom linter options
M.setup_linters = function()
	for name, data in pairs(linters) do
		local linter = lint.linters[name] or {}

		linter.cmd = data.cmd or linter.cmd
		linter.args = data.args or linter.args
		linter.stdin = data.stdin or linter.stdin
		linter.ignore_exitcode = data.ignore_exitcode or linter.ignore_exitcode
		linter.parser = data.parser or linter.parser

		lint.linters[name] = linter
	end
end

return M
