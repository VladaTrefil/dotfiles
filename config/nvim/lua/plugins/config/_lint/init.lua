local lint_ok, lint = pcall(require, 'lint')

if not lint_ok then
	vim.notify('nvim-lint not found', vim.log.levels.ERROR)
	return
end

local linters = require('plugins.config._lint.linters')
local lint_utils = require('plugins.config._lint.utils')

local disable_linting = false
local lint_events = { 'BufEnter', 'BufWritePost', 'InsertLeave', 'TextChanged' }
local ignore_filetypes = { 'help' }

lint.linters_by_ft = {
	sh = { 'shellcheck' },
	bash = { 'shellcheck' },
	-- javascript = { 'standardjs' },
	-- typescript = { 'standardjs' },
	lua = { 'selene' },
	scss = { 'stylelint' },
	-- sass = { 'stylelint' },
	ruby = { 'rubocop' },
	json = { 'jsonlint' },
	['*'] = { 'codespell' },
}

-- Highlight vertical tab as error
vim.api.nvim_command('match RedSign /\\%x0b/')

vim.g.disable_linting = disable_linting

-- Setup custom linter options
for name, data in pairs(linters) do
	local linter = lint.linters[name]
	linter.cmd = data.cmd or linter.cmd
	linter.args = data.args or linter.args
	linter.stdin = data.stdin or linter.stdin
	linter.parser = data.parser or linter.parser
end

local function lint_callback()
	lint_utils.exec_lint(lint, ignore_filetypes)
end

local lint_augroup = vim.api.nvim_create_augroup('linting', { clear = true })
vim.api.nvim_create_autocmd(lint_events, {
	group = lint_augroup,
	callback = lint_utils.debounce(100, lint_callback),
})
