local present, lualine = pcall(require, 'lualine')

if not present then
	return
end

local colors = require('theme.colors')

local function file_path()
	local path = vim.fn.expand('%f')
	local _, count = path:gsub('/', '')

	if count > 3 then
		local path_ary = vim.fn.split(path, '/')

		for index, value in ipairs(path_ary) do
			local diff = count - index

			if diff >= 3 then
				path_ary[index] = value:sub(1, 1)
			elseif diff >= 1 then
				path_ary[index] = value:sub(1, 3)
			else
				path_ary[index] = value
			end
		end

		return vim.fn.join(path_ary, '/')
	else
		return path
	end
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
		lualine_c = { 'fileformat' },
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
