local indentline_ok, indentline = pcall(require, 'ibl')

if not indentline_ok then
	return
end

local highlight = {
	'Bg2',
	'Bg4',
}

indentline.setup({
	debounce = 100,
	indent = {
		highlight = highlight,
		char = '┃',
		tab_char = '┃',
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
