vim.cmd('highlight clear')

if vim.fn.exists('syntax_on') then
	vim.cmd('syntax reset')
end

vim.o.background = 'dark'
vim.o.termguicolors = true

local highlight_groups = {
	base = { 'base', 'highlight_groups' },
	plugins = {
		'telescope',
		'lualine',
		'easymotion',
		'cmp',
		'gitgutter',
		'indentline',
		'bufferline',
	},
	syntax = {
		'base',
		'lua',
		'vim',
		'javascript',
		'java',
		'json',
		'ruby',
		'xml',
		'css',
		'html',
		'markdown',
		'rasi',
	},
}

local highlights = {}

for _, module in ipairs(highlight_groups.base) do
	highlights = vim.tbl_deep_extend('force', highlights, require('theme.' .. module))
end

for _, module in ipairs(highlight_groups.plugins) do
	highlights = vim.tbl_deep_extend('force', highlights, require('theme.plugins.' .. module))
end

for _, module in ipairs(highlight_groups.syntax) do
	highlights = vim.tbl_deep_extend('force', highlights, require('theme.syntax.' .. module))
end

for group, spec in pairs(highlights) do
	vim.api.nvim_set_hl(0, group, spec)
end
