local lint_ok, lint = pcall(require, 'lint')

if not lint_ok then
	vim.notify('nvim-lint not found', vim.log.levels.ERROR)
	return
end

local disable_linting = false

lint.linters_by_ft = {
	sh = { 'shellcheck' },
	bash = { 'shellcheck' },
	-- javascript = { 'standardjs' },
	-- typescript = { 'standardjs' },
	lua = { 'selene' },
	scss = { 'stylelint' },
	sass = { 'stylelint' },
	ruby = { 'rubocop' },
}

lint.linters.shellcheck.args = {
	'--format',
	'json',
	'-',
}

lint.linters.stylelint.args = {
	'--config',
	vim.fn.expand('$XDG_CONFIG_HOME/stylelint/stylelintrc.json'),
}

lint.linters.codespell.args = {
	'--ignore-words',
	vim.fn.expand('$XDG_CONFIG_HOME/codespell/ignore.txt'),
	'--exclude-file',
	vim.fn.expand('$XDG_CONFIG_HOME/codespell/exclude-file.txt'),
	'--config',
	vim.fn.expand('$XDG_CONFIG_HOME/codespell/codespellrc'),
	'--regex',
	"(?<![a-z])[a-z'`]+|[A-Z][a-z'`]*|[a-z]+'[a-z]*|[a-z]+(?=[_-])|[a-z]+(?=[A-Z])|\\d+",
}

lint.linters.rubocop.cmd = 'bundle'
lint.linters.rubocop.stdin = true
lint.linters.rubocop.args = {
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
}

vim.g.disable_linting = disable_linting

local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave', 'TextChanged' }, {
	group = lint_augroup,
	callback = function()
		lint.try_lint()
		lint.try_lint('codespell')
	end,
})
