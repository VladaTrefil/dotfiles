local colors = require('theme.colors')

local config = {
  htmlTag = { link = 'Blue' },
  htmlEndTag = { link = 'Blue' },

  htmlTagName = { link = 'AquaBold' },
  htmlArg = { link = 'Aqua' },

  htmlScriptTag = { link = 'Purple' },
  htmlTagN = { link = 'Fg1' },
  htmlSpecialTagName = { link = 'AquaBold' },

  htmlLink = { fg = colors.light4, bg = colors.none, underline = true },

  htmlSpecialChar = { link = 'Orange' },

  htmlBold = { fg = colors.light0, bg = colors.dark0, bold = true },
  htmlBoldUnderline = { fg = colors.light0, bg = colors.dark0, bold = true, underline = true },
  htmlBoldItalic = { fg = colors.light0, bg = colors.dark0, bold = true, italic = true },
  htmlBoldUnderlineItalic = { fg = colors.light0, bg = colors.dark0, bold = true, underline = true, italic = true },

  htmlUnderline = { fg = colors.light0, bg = colors.dark0, underline = true },
  htmlUnderlineItalic = { fg = colors.light0, bg = colors.dark0, underline = true, italic = true },
  htmlItalic = { fg = colors.light0, bg = colors.dark0, italic = true },
}

return config
