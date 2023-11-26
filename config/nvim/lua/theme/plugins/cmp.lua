local colors = require('theme.colors')

local cmp_colors = {
	primary_bg = colors.dark,
	secondary_bg = colors.dark2,
}

local config = {
	CmpPmenu = { fg = colors.light0, bg = cmp_colors.primary_bg },
	CmpPmenuDocumentation = { fg = colors.light0, bg = cmp_colors.secondary_bg },
	CmpPmenuSel = { bg = cmp_colors.secondary_bg },

	CmpItemAbbrDeprecated = { fg = colors.gray, strikethrough = true },
	CmpItemAbbrMatch = { fg = colors.bright_orange },
	CmpItemAbbrMatchFuzzy = { fg = colors.bright_orange },

	CmpItemKind = { fg = colors.gray },
	CmpItemKindCopilot = { fg = colors.gray },

	CmpItemMenuCopilot = { bg = colors.light0, fg = cmp_colors.primary_bg },
	CmpItemMenuNvimLsp = { bg = colors.bright_orange, fg = cmp_colors.primary_bg },
	CmpItemMenuUltisnips = { bg = colors.bright_blue, fg = cmp_colors.primary_bg },
	CmpItemMenuCmdline = { bg = colors.bright_aqua, fg = cmp_colors.primary_bg },
	CmpItemMenuBuffer = { bg = cmp_colors.primary_bg, fg = colors.light0 },
	CmpItemMenuPath = { bg = colors.gray, fg = cmp_colors.primary_bg },
}

return config
