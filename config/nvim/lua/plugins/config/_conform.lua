local conform_ok, conform = pcall(require, 'conform')

if not conform_ok then
	vim.notify('Conform not found', vim.log.levels.ERROR)
	return
end

local ignore_filetypes = { 'javascript', 'sass' }
local disable_autoformat = false

local formatters = {
	stylua = {
		prepend_args = {
			'--config-path',
			vim.fn.expand('$XDG_CONFIG_HOME/stylua/stylua.toml'),
		},
	},
	stylelint = {
		prepend_args = {
			'--config',
			vim.fn.expand('$XDG_CONFIG_HOME/stylelint/stylelintrc.json'),
		},
	},
	rubocop = {
		command = 'bundle',
		prepend_args = {
			'exec',
			'rubocop',
			'--force-exclusion',
			'--config',
			vim.fn.expand('$XDG_CONFIG_HOME/rubocop/rubocop.yml'),
			'--stdin',
			'$FILENAME',
		},
		condition = function()
			return vim.fn.executable('rubocop') > 0
		end,
		-- env = {
		--   VAR = "value",
		-- },
	},
}

local autoformat_opts = {
	timeout_ms = 3000,
	lsp_fallback = true,
}

vim.g.disable_autoformat = disable_autoformat

conform.setup({
	formatters_by_ft = {
		lua = { 'stylua' },
		ruby = { 'rubocop' },
		-- sass = { 'prettier' },
		scss = { 'prettier' },
		js = { 'prettier' },
		json = { 'prettier' },
		sh = { 'beautysh' },
		yaml = { 'prettier' },
		['_'] = { 'trim_whitespace' },
	},

	formatters = formatters,

	log_level = vim.log.levels.WARN,
	format_on_save = function(bufnr)
		-- Disable autoformat on certain filetypes
		if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
			return
		end

		-- Disable with a global or buffer-local variable
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end

		-- Disable autoformat for files in a certain path
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		if bufname:match('/node_modules/') then
			return
		end

		return autoformat_opts
	end,
})
