local null_ls_ok, null_ls = pcall(require, 'null-ls')
local mason_null_ls_ok, mason_null_ls = pcall(require, 'mason-null-ls')

if not null_ls_ok or not mason_null_ls_ok then
	vim.notify("null_ls or mason_null_ls lua package doesn't exist ")
	return
end

local utils = require('core.utils')
local mappings = require('core.mappings').codespell

local lspconf_utils = require('lspconfig.util')

local sources_config = {
	stylelint = {
		extra_args = {
			'--config',
			vim.fn.expand('$XDG_CONFIG_HOME/stylelint/stylelintrc.json'),
		},
	},
	-- codespell = {
	-- 	extra_args = {
	-- 		'--ignore-words',
	-- 		vim.fn.expand('$XDG_CONFIG_HOME/codespell/ignore.txt'),
	-- 		'--exclude-file',
	-- 		vim.fn.expand('$XDG_CONFIG_HOME/codespell/exclude-file.txt'),
	-- 		'--config',
	-- 		vim.fn.expand('$XDG_CONFIG_HOME/codespell/codespellrc'),
	-- 		'--regex',
	-- 		"(?<![a-z])[a-z'`]+|[A-Z][a-z'`]*|[a-z]+'[a-z]*|[a-z]+(?=[_-])|[a-z]+(?=[A-Z])|\\d+",
	-- 	},
	-- },
	shellcheck = {
		diagnostic_config = {
			underline = true,
			virtual_text = false,
			signs = true,
			update_in_insert = false,
			severity_sort = true,
		},
		condition = function()
			-- exclude if file name is .env
			return vim.fn.expand('%:t') ~= '.env'
		end,
	},
	rubocop = {
		command = 'bundle exec rubocop',
		args = {
			'--config',
			vim.fn.expand('$XDG_CONFIG_HOME/rubocop/rubocop.yml'),
			'--require rubocop-rails',
			'--require rubocop-performance',
			'-A',
			'-f',
			'quiet',
			'--stderr',
			'--stdin',
			'$FILENAME',
		},
		condition = function()
			return vim.fn.executable('rubocop') > 0
		end,
		-- env = {
		-- 	PRETTIERD_DEFAULT_CONFIG = vim.fn.expand(
		-- 		'~/.config/nvim/utils/linter-config/.prettierrc.json'
		-- 	),
		-- },
	},
}

-- setup mason_null_ls before null_ls
mason_null_ls.setup({
	ensure_installed = {},
	automatic_installation = false,
	automatic_setup = true, -- Recommended, but optional
	handlers = {},
})

null_ls.setup({
	root_dir = lspconf_utils.root_pattern('Gemfile', '.git'),
	sources = {
		-- null_ls.builtins.diagnostics.dotenv_linter,
		null_ls.builtins.diagnostics.trail_space,
		null_ls.builtins.diagnostics.stylelint.with(sources_config.stylelint),
		null_ls.builtins.diagnostics.codespell.with(sources_config.codespell),
		null_ls.builtins.diagnostics.shellcheck.with(sources_config.shellcheck),
		-- null_ls.builtins.diagnostics.rubocop.with(sources_config.rubocop),

		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.stylelint,

		-- null_ls.builtins.diagnostics.deno_lint,
		-- null_ls.builtins.formatting.beautysh,
		-- null_ls.builtins.formatting.clang_format,
		-- null_ls.builtins.diagnostics.clang_check,
		-- null_ls.builtins.diagnostics.tsc,
		-- null_ls.builtins.diagnostics.eslint_d,
		-- null_ls.builtins.diagnostics.zsh,
		-- null_ls.builtins.diagnostics.yamllint,
	},
})

utils.load_mappings(mappings)
