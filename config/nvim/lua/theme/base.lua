local colors = require('theme.colors')

local config = {
  Normal = { fg = colors.light0, bg = colors.dark0 },
  Visual = { bg = colors.dark3, reverse = true },

  TabLineFill = { fg = colors.light0, bg = colors.dark0, reverse = true },
  TabLineSel = { fg = colors.bright_aqua, bg = colors.dark0, reverse = true },

  Conceal = { fg = colors.bright_blue },
  Search = { fg = colors.orange, bg = colors.dark0, reverse = true },
  IncSearch = { fg = colors.faded_red, bg = colors.dark0, reverse = true },
  CurSearch = { fg = colors.red, bg = colors.dark0, reverse = true },
  Underlined = { fg = colors.bright_blue, underline = true },
  VertSplit = { fg = colors.dark2, bg = colors.dark0 },
  WildMenu = { fg = colors.bright_blue, bg = colors.dark2, bold = true },
  ErrorMsg = { fg = colors.dark0, bg = colors.bright_red, bold = true },

  EndOfBuffer = { fg = colors.dark0, bg = colors.dark0 },
  LineNr = { fg = colors.gray },
  SignColumn = { fg = colors.light2, bg = colors.dark0 },
  Folded = { fg = colors.faded_blue, bg = colors.dark0, italic = true },

  Cursor = { fg = colors.dark0, bg = colors.light0 },
  CursorLine = { bg = colors.dark1 },
  CursorLineNr = { fg = colors.bright_orange, bg = colors.dark0 },

  MatchParen = { fg = colors.dark0, bg = colors.bright_blue, bold = true },

  MoreMsg = { link = 'YellowBold' },
  ModeMsg = { link = 'YellowBold' },
  Question = { link = 'OrangeBold' },
  WarningMsg = { link = 'RedBold' },
  Directory = { link = 'GreenBold' },
  Title = { link = 'GreenBold' },
  NonText = { link = 'Bg2' },
  SpecialKey = { link = 'Bg2' },
  TabLine = { link = 'TabLineFill' },
  VisualNOS = { link = 'Visual' },
  iCursor = { link = 'Cursor' },
  lCursor = { link = 'Cursor' },

  Pmenu = { fg = colors.light1, bg = colors.dark2 },
  PmenuSel = { fg = colors.light0, bg = colors.dark4 },
  PmenuSbar = { bg = colors.dark2 },
  PmenuThumb = { bg = colors.dark4 },

  -- Diff
  DiffDelete = { fg = colors.bright_red, bg = colors.dark0, reverse = true },
  DiffAdd = { fg = colors.bright_green, bg = colors.dark0, reverse = true },
  DiffChange = { fg = colors.bright_aqua, bg = colors.dark0, reverse = true },
  DiffText = { fg = colors.bright_yellow, bg = colors.dark0, reverse = true },

  diffAdded = { link = 'Green' },
  diffRemoved = { link = 'Red' },
  diffChanged = { link = 'Aqua' },
  diffFile = { link = 'Orange' },
  diffNewFile = { link = 'Yellow' },
  diffLine = { link = 'Blue' },
}

if vim.fn.has('spell') then
  local spell_config = {
    SpellCap = { fg = colors.bright_green, bold = true, italic = true },
    SpellBad = { undercurl = true, sp = colors.bright_blue },
    SpellLocal = { undercurl = true, sp = colors.bright_aqua },
    SpellRare = { undercurl = true, sp = colors.bright_purple },
  }

  config = vim.tbl_deep_extend('force', config, spell_config)
end

return config
