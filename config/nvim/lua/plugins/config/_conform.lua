local conform_ok, conform = pcall(require, 'conform')

if not conform_ok then
	vim.notify('Conform not found', vim.log.levels.ERROR)
	return
end

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
			'--config',
			vim.fn.expand('$XDG_CONFIG_HOME/rubocop/rubocop.yml'),
		},
		condition = function()
			return vim.fn.executable('rubocop') > 0
		end,
		-- env = {
		--   VAR = "value",
		-- },
	},
}

conform.setup({
	formatters_by_ft = {
		lua = { 'stylua' },
		ruby = { 'rubocop' },
		-- sass = { 'prettier' },
		scss = { 'prettier' },
		js = { 'prettier' },
		json = { 'prettier' },
		sh = { 'shellcheck' },
		yaml = { 'prettier' },
		['_'] = { 'trim_whitespace' },
	},

	formatters = formatters,

	log_level = vim.log.levels.WARN,
	format_on_save = {
		-- I recommend these options. See :help conform.format for details.
		lsp_fallback = true,
		timeout_ms = 2000,
	},
})
