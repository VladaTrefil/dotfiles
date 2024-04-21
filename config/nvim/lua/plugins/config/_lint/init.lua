local lint_ok, lint = pcall(require, 'lint')

if not lint_ok then
	vim.notify('nvim-lint not found', vim.log.levels.ERROR)
	return
end

lint.linters_by_ft = {
	sh = { 'shellcheck' },
	bash = { 'shellcheck' },
	javascript = { 'standardjs' },
	typescript = { 'standardjs' },
	lua = { 'selene' },
	scss = { 'stylelint' },
	sass = { 'stylelint' },
	ruby = { 'rubocop' },
	python = { 'mypy', 'pylint' },
	slim = { 'slimlint' },
	json = { 'jsonlint' },
	['*'] = { 'codespell' },
}

local utils = require('core.utils')
local lint_utils = require('plugins.config._lint.utils')

local lint_events = { 'BufEnter', 'BufWritePost', 'InsertLeave', 'TextChanged' }

local ignore_filetypes = { 'help' }
local ignore_paths = { '.env', '.env.sample' }

local linters = require('plugins.config._lint.linters')
lint_utils.setup_linters(linters)

vim.g.disable_linting = false

local function lint_callback()
	local ignored_path = false
	for _, path in ipairs(ignore_paths) do
		if string.match(vim.api.nvim_buf_get_name(0), path) then
			ignored_path = true
		end
	end

	if
		vim.tbl_contains(ignore_filetypes, vim.bo.filetype)
		or ignored_path
		or utils.filesize_kb() > 128
		or vim.g.disable_linting
	then
		return
	end

	lint_utils.exec_lint(lint)
end

local lint_augroup = vim.api.nvim_create_augroup('linting', { clear = true })
vim.api.nvim_create_autocmd(lint_events, {
	group = lint_augroup,
	callback = lint_utils.debounce(100, lint_callback),
})

-- Highlight vertical tab as error
vim.api.nvim_command('match RedSign /\\%x0b/')
