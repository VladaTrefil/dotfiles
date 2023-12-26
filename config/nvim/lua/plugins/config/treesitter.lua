local treesitter_ok, _ = pcall(require, 'nvim-treesitter')

if not treesitter_ok then
	return
end

local FILETYPES = {
	'c',
	'lua',
	'luap',
	'javascript',
	'typescript',
	'rust',
	'ruby',
	'python',
	'bash',
	'scss',

	-- Markup
	'json',
	'yaml',
	'toml',
	'xml',
	'yuck',
	'rasi',
	'vimdoc',
	'dockerfile',
	'git_config',
	'gitignore',
}

require('nvim-treesitter.configs').setup({
	-- A list of parser names, or "all"
	ensure_installed = FILETYPES,
	ignore_install = {},
	modules = {},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

	incremental_selection = { enable = true },

	-- TODO: Indent is usually wrong, see
	-- https://github.com/nvim-treesitter/nvim-treesitter/issues/2507
	indent = {
		enable = false,
	},

	highlight = {
		-- `false` will disable the whole extension
		enable = true,

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
})

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
-- set all folds to unfold on open
vim.opt.foldlevel = 99
