local colors = require('theme.colors')

local config = {
  Special = { fg = colors.bright_orange, bg = colors.dark1, italic = true },
  Comment = { fg = colors.gray, bg = colors.dark1, italic = true },
  Todo = { fg = colors.light0, bold = true, italic = true },
  Error = { fg = colors.bright_red, bg = colors.dark0, bold = true, undercurl = true },
  String = { fg = colors.bright_green, bg = colors.none, italic = true },
  Type = { fg = colors.faded_blue, },

  Statement = { link = 'PurpleBold' },
  Conditional = { link = 'Aqua' },
  Repeat = { link = 'Aqua' },
  Label = { link = 'Red' },
  Exception = { link = 'Red' },
  Operator = { link = 'Normal' },
  Keyword = { link = 'Red' },

  Identifier = { link = 'Blue' },
  Function = { link = 'GreenBold' },

  PreProc = { link = 'Aqua' },
  Include = { link = 'Aqua' },
  Define = { link = 'Aqua' },
  Macro = { link = 'Aqua' },
  PreCondit = { link = 'Aqua' },

  Constant = { link = 'Purple' },
  Character = { link = 'Green' },
  Boolean = { link = 'Purple' },
  Number = { link = 'Orange' },
  Float = { link = 'Orange' },

  StorageClass = { link = 'Orange' },
  Structure = { link = 'Aqua' },
  Typedef = { link = 'Yellow' },
}

return config
