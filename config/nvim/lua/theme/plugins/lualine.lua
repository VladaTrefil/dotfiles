local colors = require('theme.colors')

local config = {
	lualine_a_normal = { fg = colors.dark0, bg = colors.bright_blue, bold = true },
	lualine_b_normal = { fg = colors.light0, bg = colors.dark2, bold = true },
	lualine_c_normal = { fg = colors.dark0, bg = colors.dark0, bold = true },
	lualine_a_insert = { fg = colors.dark0, bg = colors.yellow, bold = true },
	lualine_a_replace = { fg = colors.dark0, bg = colors.orange, bold = true },
	lualine_a_visual = { fg = colors.light0, bg = colors.bright_red, bold = true },
	lualine_a_inactive = { fg = colors.dark2, bg = colors.dark1 },
	lualine_b_inactive = { bg = colors.dark1 },
	lualine_c_inactive = { bg = colors.dark1 },
}

return config
