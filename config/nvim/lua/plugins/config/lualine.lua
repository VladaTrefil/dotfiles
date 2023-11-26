local present, lualine = pcall(require, 'lualine')

if not present then
	return
end

local colors = require('theme.colors')
local utils = require('core.utils')

local function file_path()
	local path = vim.fn.expand('%f')
	return utils.truncate_path(path, 3, 3, 5)
end

local bubbles_theme = {
	normal = {
		a = { fg = colors.dark0, bg = colors.bright_blue },
		b = { fg = colors.light0, bg = colors.dark2 },
		c = { fg = colors.light1, bg = colors.dark1 },
		z = { fg = colors.dark0, bg = colors.bright_blue },
	},

	insert = { a = { fg = colors.dark0, bg = colors.bright_yellow } },
	visual = { a = { fg = colors.light0, bg = colors.bright_red } },
	replace = { a = { fg = colors.dark0, bg = colors.bright_orange } },

	inactive = {
		a = { fg = colors.light3, bg = colors.dark2 },
		b = { fg = colors.light3, bg = colors.dark0 },
		c = { fg = colors.gray, bg = colors.dark0 },
	},
}

lualine.setup({
	options = {
		theme = bubbles_theme,
		component_separators = '|',
		section_separators = { left = '', right = '' },
		padding = { left = 1, right = 1 },
		disabled_filetypes = {
			statusline = {
				'alpha',
			},
		},
	},
	sections = {
		lualine_b = {
			{ file_path, padding = { left = 2, right = 2 } },
			{ 'branch', padding = { left = 2, right = 2 } },
		},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {
			{ 'filetype' },
			{ 'progress' },
		},
		lualine_z = {
			{
				'location',
				padding = { left = 1, right = 1 },
			},
		},
	},
	inactive_sections = {
		-- lualine_b = {},
		-- lualine_c = {},
		-- lualine_x = {},
		-- lualine_y = {},
		lualine_z = {
			{ 'filetype', padding = { right = 2, left = 2 } },
		},
	},
	tabline = {},
	extensions = {},
})
