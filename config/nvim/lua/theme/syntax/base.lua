local colors = require('theme.colors')

local config = {
	Special = { fg = colors.blue, bg = colors.dark1, italic = true },
	Comment = { fg = colors.gray, bg = colors.dark1, italic = true },
	Todo = { fg = colors.light0, bold = true, italic = true },
	Error = { fg = colors.bright_red, bg = colors.dark0, bold = true, undercurl = true },
	String = { fg = colors.green, bg = colors.none, italic = true },
	Type = { link = 'Aqua' },

	Statement = { link = 'PurpleBold' },
	Conditional = { link = 'Aqua' },
	Repeat = { link = 'Aqua' },
	Label = { link = 'Aqua' },
	Exception = { link = 'Red' },
	Operator = { fg = colors.light3 },
	Keyword = { link = 'Blue' },

	Identifier = { link = 'Orange' },
	Function = { link = 'GreenBold' },

	PreProc = { link = 'Aqua' },
	Include = { link = 'Aqua' },
	Define = { link = 'Aqua' },
	Macro = { link = 'Aqua' },
	PreCondit = { link = 'Aqua' },

	Constant = { link = 'Yellow' },
	Character = { link = 'Green' },
	Boolean = { link = 'Purple' },
	Number = { link = 'Yellow' },
	Float = { link = 'Yellow' },

	StorageClass = { fg = colors.light3 },
	Structure = { link = 'Aqua' },
	Typedef = { link = 'Yellow' },
}

return config
