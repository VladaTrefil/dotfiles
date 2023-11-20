local colors = require('theme.colors')

local config = {
	markdownItalic = { fg = colors.light3, bg = colors.none, italic = true },

	markdownH1 = { link = 'GreenBold' },
	markdownH2 = { link = 'GreenBold' },
	markdownH3 = { link = 'YellowBold' },
	markdownH4 = { link = 'YellowBold' },
	markdownH5 = { link = 'Yellow' },
	markdownH6 = { link = 'Yellow' },

	markdownCode = { link = 'Aqua' },
	markdownCodeBlock = { link = 'Aqua' },
	markdownCodeDelimiter = { link = 'Aqua' },

	markdownBlockquote = { link = 'Gray' },
	markdownListMarker = { link = 'Gray' },
	markdownOrderedListMarker = { link = 'Gray' },
	markdownRule = { link = 'Gray' },
	markdownHeadingRule = { link = 'Gray' },

	markdownUrlDelimiter = { link = 'Fg3' },
	markdownLinkDelimiter = { link = 'Fg3' },
	markdownLinkTextDelimiter = { link = 'Fg3' },

	markdownHeadingDelimiter = { link = 'Orange' },
	markdownUrl = { link = 'Purple' },
	markdownUrlTitleDelimiter = { link = 'Green' },

	markdownLinkText = { fg = colors.gray, bg = colors.none, underline = true },
	markdownIdDeclaration = { link = 'markdownLinkText' },
}

return config
