local colors = require('theme.colors')

local config = {
	Fg0 = { fg = colors.light0 },
	Fg1 = { fg = colors.light1 },
	Fg2 = { fg = colors.light2 },
	Fg3 = { fg = colors.light3 },
	Fg4 = { fg = colors.light4 },

	Gray = { fg = colors.gray },

	Bg0 = { fg = colors.dark0 },
	Bg1 = { fg = colors.dark1 },
	Bg2 = { fg = colors.dark2 },
	Bg3 = { fg = colors.dark3 },
	Bg4 = { fg = colors.dark4 },

	Red = { fg = colors.bright_red },
	RedBold = { fg = colors.bright_red, bold = true },
	Green = { fg = colors.bright_green },
	GreenBold = { fg = colors.bright_green, bold = true },
	Yellow = { fg = colors.bright_yellow },
	YellowBold = { fg = colors.bright_yellow, bold = true },
	Blue = { fg = colors.bright_blue },
	BlueBold = { fg = colors.bright_blue, bold = true },
	Purple = { fg = colors.purple },
	PurpleBold = { fg = colors.bright_purple, bold = true },
	Aqua = { fg = colors.bright_aqua },
	AquaBold = { fg = colors.bright_aqua, bold = true },
	Orange = { fg = colors.bright_orange },
	OrangeBold = { fg = colors.bright_orange, bold = true },

	RedSign = { fg = colors.bright_red, bold = true },
	GreenSign = { fg = colors.bright_green, bold = true },
	YellowSign = { fg = colors.bright_yellow, bold = true },
	BlueSign = { fg = colors.blue, bold = true },
	PurpleSign = { fg = colors.bright_purple, bold = true },
	AquaSign = { fg = colors.bright_aqua, bold = true },
	OrangeSign = { fg = colors.orange, bold = true },
}

return config
