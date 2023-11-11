local colors = require('theme.colors')

local prompt_background = colors.dark
local results_background = colors.dark
local preview_background = colors.dark1

local config = {
	TelescopePromptNormal = { link = 'Pmenu' },
	TelescopePromptBorder = { link = 'PmenuBorder' },
	TelescopePromptTitle = { fg = prompt_background, bg = colors.blue },
	TelescopePromptCounter = { fg = colors.light4 },
	TelescopePromptPrefix = { fg = colors.blue },

	TelescopeSelectionCaret = { fg = colors.bright_yellow },
	TelescopeMatching = { fg = colors.bright_yellow, bg = colors.dark },
	TelescopeSelection = { fg = colors.orange, bg = colors.dark1 },
	TelescopeMultiSelection = { fg = colors.blue },
	TelescopeMultiIcon = { fg = colors.blue },
	TelescopeNormal = { fg = colors.light0, bg = preview_background },
	TelescopeBorder = { fg = colors.dark0 },
	TelescopeTitle = { fg = colors.light0 },

	TelescopePreviewNormal = { fg = colors.light0, bg = preview_background },
	TelescopePreviewTitle = { fg = colors.dark1, bg = preview_background },
	TelescopePreviewBorder = { fg = preview_background, bg = preview_background },
	TelescopePreviewLine = { fg = colors.light0, bg = colors.gray },
	TelescopePreviewMatch = { fg = colors.yellow },
	TelescopePreviewPipe = { fg = colors.yellow },
	TelescopePreviewCharDev = { fg = colors.yellow },
	TelescopePreviewDirectory = { fg = colors.blue },
	TelescopePreviewBlock = { fg = colors.yellow },
	TelescopePreviewLink = { fg = colors.blue },
	TelescopePreviewSocket = { fg = colors.purple },
	TelescopePreviewRead = { fg = colors.yellow },
	TelescopePreviewWrite = { fg = colors.purple },
	TelescopePreviewExecute = { fg = colors.green },
	TelescopePreviewHyphen = { fg = colors.grey },
	TelescopePreviewSticky = { fg = colors.blue },
	TelescopePreviewSize = { fg = colors.green },
	TelescopePreviewUser = { fg = colors.yellow },
	TelescopePreviewGroup = { fg = colors.yellow },
	TelescopePreviewDate = { fg = colors.blue },
	TelescopePreviewMessage = { fg = colors.light0 },
	TelescopePreviewMessageFillchar = { fg = colors.light0 },

	TelescopeResultsTitle = { fg = results_background },
	TelescopeResultsBorder = { fg = results_background, bg = results_background },
	TelescopeResultsNormal = { fg = colors.light0, bg = results_background },
	TelescopeResultsClass = { fg = colors.yellow },
	TelescopeResultsConstant = { fg = colors.yellow },
	TelescopeResultsField = { fg = colors.red },
	TelescopeResultsFunction = { fg = colors.blue },
	TelescopeResultsMethod = { fg = colors.blue },
	TelescopeResultsOperator = { fg = colors.aqua },
	TelescopeResultsStruct = { fg = colors.purple },
	TelescopeResultsVariable = { fg = colors.red },
	TelescopeResultsLineNr = { fg = colors.light1 },
	TelescopeResultsIdentifier = { fg = colors.blue },
	TelescopeResultsNumber = { fg = colors.orange },
	TelescopeResultsComment = { fg = colors.light3 },
	TelescopeResultsSpecialComment = { fg = colors.grey },
	TelescopeResultsDiffChange = { fg = colors.none, bg = colors.yellow },
	TelescopeResultsDiffAdd = { fg = colors.none, bg = colors.green },
	TelescopeResultsDiffDelete = { fg = colors.none, bg = colors.red },
	TelescopeResultsDiffUntracked = { fg = colors.none, bg = colors.light4 },
}

return config
