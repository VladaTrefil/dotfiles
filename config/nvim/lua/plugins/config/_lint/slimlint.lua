local severity_map = {
	['E'] = vim.diagnostic.severity.ERROR,
	['W'] = vim.diagnostic.severity.WARN,
	['I'] = vim.diagnostic.severity.INFO,
}

return {
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
				lnum = tonumber(lnum) or 0,
				severity = severity_map[severity],
				message = message,
				file = file,
			},
		}
	end,
}
