local conform_ok, conform = pcall(require, 'conform')

if not conform_ok then
	vim.notify('Conform not found', vim.log.levels.ERROR)
	return
end

local ignore_filetypes = { 'sass' }
local disable_autoformat = false

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
}

local autoformat_opts = {
	timeout_ms = 3000,
	lsp_fallback = true,
}

vim.g.disable_autoformat = disable_autoformat

local format_on_save = function(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	-- Disable autoformat on certain filetypes
	if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
		return false
	end

	-- Disable with a global or buffer-local variable
	if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
		return false
	end

	-- disable autoformat for files larger than 128KB
	if vim.fn.getfsize(vim.fn.expand('%')) > 128 * 1024 then
		return false
	end

	-- Disable autoformat for minified files
	if bufname:match('.min.') then
		return false
	end

	-- Disable autoformat for files in a certain path
	if bufname:match('/node_modules/') then
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
		['_'] = { 'trim_whitespace' },
	},

	formatters = formatters,

	log_level = vim.log.levels.WARN,
	format_on_save = format_on_save,
})
