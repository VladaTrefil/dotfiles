local colors = require('theme.colors')

local config = {
	ChatGPTWelcome = { fg = colors.faded_purple, bg = colors.dark },
	ChatGPTQuestion = { fg = colors.bright_orange, bg = colors.dark },
	ChatGPTCompletion = { fg = colors.blue, bg = colors.dark },
	ChatGPTMessageAction = { fg = colors.blue, bg = colors.dark },
	ChatGPTSelectedMessage = { fg = colors.light0, bg = colors.dark2 },
	ChatGPTTotalTokensBorder = { fg = colors.dark, bg = colors.dark },
	ChatGPTTotalTokens = { fg = colors.faded_purple, bg = colors.dark },

	ChatGPTSettingsBorder = { fg = colors.orange, bg = colors.dark },
	ChatGPTSessionsBorder = { fg = colors.orange, bg = colors.dark },
	ChatGPTInputBorder = { fg = colors.bright_purple, bg = colors.dark },
	ChatGPTSystemBorder = { fg = colors.faded_blue, bg = colors.dark },
}

return config
