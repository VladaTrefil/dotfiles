local indentline_ok, indentline = pcall(require, 'ibl')

if not indentline_ok then
	return
end

local icons = require('core.icons')

local highlight = {
	'Bg2',
	'Bg4',
}

indentline.setup({
	debounce = 100,
	indent = {
		highlight = highlight,
		char = icons.PipeThick,
		tab_char = icons.PipeThick,
	},
	whitespace = {
		highlight = highlight,
		remove_blankline_trail = false,
	},
	scope = { highlight = 'Gray' },
	exclude = {
		filetypes = {
			'help',
			'terminal',
			'alpha',
			'packer',
			'lspinfo',
			'TelescopePrompt',
			'TelescopeResults',
			'mason',
			'dashboard',
		},
		buftypes = { 'terminal' },
	},
})
