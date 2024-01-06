local lint_ok, lint = pcall(require, 'lint')

if not lint_ok then
	vim.notify('nvim-lint not found', vim.log.levels.ERROR)
	return
end

local lint_utils = require('plugins.config._lint.utils')
local linters = require('plugins.config._lint.linters')

local disable_linting = false
local lint_events = { 'BufEnter', 'BufWritePost', 'InsertLeave', 'TextChanged' }
local ignore_filetypes = { 'help' }

lint.linters_by_ft = {
	sh = { 'shellcheck' },
	bash = { 'shellcheck' },
	javascript = { 'standardjs' },
	typescript = { 'standardjs' },
	lua = { 'selene' },
	scss = { 'stylelint' },
	sass = { 'stylelint' },
	ruby = { 'rubocop' },
	json = { 'jsonlint' },
	['*'] = { 'codespell' },
}

linters.setup_linters()

-- Highlight vertical tab as error
vim.api.nvim_command('match RedSign /\\%x0b/')

vim.g.disable_linting = disable_linting

local function lint_callback()
	lint_utils.exec_lint(lint, ignore_filetypes)
end

local lint_augroup = vim.api.nvim_create_augroup('linting', { clear = true })
vim.api.nvim_create_autocmd(lint_events, {
	group = lint_augroup,
	callback = lint_utils.debounce(100, lint_callback),
})
