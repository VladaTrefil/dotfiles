local colors = require('theme.colors')

local cmp_bg = colors.dark

local config = {
  CmpPmenu = { fg = colors.light0, bg = cmp_bg },
  CmpPmenuBorder = { fg = colors.dark1, bg = cmp_bg },
  CmpPmenuSel = { bg = colors.dark1 },

  CmpItemAbbrDeprecated = { fg = colors.gray, strikethrough = true },
  CmpItemAbbrMatch = { fg = colors.bright_orange },
  CmpItemAbbrMatchFuzzy = { fg = colors.bright_orange },

  CmpItemKind = { fg = colors.gray },
  CmpItemKindCopilot = { fg = colors.gray },

  CmpItemMenuCopilot = { bg = colors.light0, fg = cmp_bg },
  CmpItemMenuNvimLsp = { bg = colors.bright_orange, fg = cmp_bg },
  CmpItemMenuUltisnips = { bg = colors.bright_blue, fg = cmp_bg },
  CmpItemMenuBuffer = { bg = cmp_bg, fg = colors.light0 },
  CmpItemMenuPath = { bg = colors.gray, fg = cmp_bg },
}

return config
