local conform_ok, conform = pcall(require, 'conform')

if not conform_ok then
	vim.notify('Conform not found', vim.log.levels.ERROR)
	return
end

local ignore_filetypes = { 'sass' }
local ignore_paths = { 'Gemfile.lock', '.min.', '/node_modules/' }
local disable_autoformat = false

local utils = require('core.utils')

local rubocop = require('plugins.config._conform.rubocop')
local stylua = require('plugins.config._conform.stylua')

local formatters = {
	stylelint = {
		prepend_args = {
			'--config',
			vim.fn.expand('$XDG_CONFIG_HOME/stylelint/stylelintrc.json'),
		},
	},
	beautysh = {
		prepend_args = {
			'--indent-size=2',
		},
	},
	rubocop = rubocop,
	stylua = stylua,
	trim_whitespace = {
		disabled_filetypes = { 'eruby' },
	},
}

local autoformat_opts = {
	timeout_ms = 3000,
	lsp_fallback = true,
}

vim.g.disable_autoformat = disable_autoformat

local format_on_save = function(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	local ignored_path = false
	for _, path in ipairs(ignore_paths) do
		if bufname:match(path) then
			ignored_path = true
		end
	end

	if
		vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype)
		or ignored_path
		or vim.g.disable_autoformat
		or vim.b[bufnr].disable_autoformat
		or utils.filesize_kb() > 128
	then
		return false
	end

	return autoformat_opts
end

conform.setup({
	formatters_by_ft = {
		lua = { 'stylua' },
		ruby = { 'rubocop' },
		python = { 'isort', 'blue' },
		-- sass = { 'prettier' },
		scss = { 'prettier' },
		javascript = { 'standardjs' },
		json = { 'prettier' },
		sh = { 'beautysh' },
		yaml = { 'prettier' },
		c = { 'clang-format' },
		['_'] = { 'trim_whitespace' },
	},

	formatters = formatters,

	log_level = vim.log.levels.WARN,
	format_on_save = format_on_save,
})
