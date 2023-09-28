local colors = require('theme.colors')

local config = {
  CmpPmenu = { fg = colors.light0, bg = colors.dark0 },
  CmpPmenuBorder = { fg = colors.bright_blue, bg = colors.dark0 },

  CmpItemAbbrDeprecated = { fg = colors.gray, bg = colors.dark0, strikethrough = true },
  CmpItemAbbrMatch = { fg = colors.bright_blue, bg = colors.dark0 },
  CmpItemAbbrMatchFuzzy = { fg = colors.bright_blue, bg = colors.dark0 },
  CmpItemKindVariable = { fg = colors.faded_blue, bg = colors.dark0 },
  CmpItemKindInterface = { fg = colors.faded_blue, bg = colors.dark0 },
  CmpItemKindText = { fg = colors.faded_blue, bg = colors.dark0 },
  CmpItemKindFunction = { fg = colors.faded_red, bg = colors.dark0 },
  CmpItemKindMethod = { fg = colors.faded_red, bg = colors.dark0 },
  CmpItemKindKeyword = { fg = colors.faded_yellow, bg = colors.dark0 },
  CmpItemKindProperty = { fg = colors.faded_yellow, bg = colors.dark0 },
  CmpItemKindUnit = { fg = colors.faded_yellow, bg = colors.dark0 },

  -- copilot
  CmpItemKindCopilot = { fg = colors.bright_blue, bg = colors.dark0 },
}

return config
