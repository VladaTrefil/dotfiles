-- Lualine:
---------------------------------------------------------------

local bg0           = '#0B0E14'
local bg1           = '#0D1017'
local bg2           = '#151f28'
local fg0           = '#E6E1CF'
local fg1           = '#E6E1CF'
local red           = '#e4445a'
local yellow        = '#E7C547'
local orange        = '#F29718'
local aqua          = '#1f997e'
local bright_red    = '#e23141'

local function file_path()
  local path = vim.fn.expand('%f')
  local path_table = vim.fn.split(path, '/')
  local result = ''

  for i = 1, table.getn(path_table), 1 do
    local r = table.getn(path_table) - i

    if ( r < 6 ) then
      if ( r > 2 ) then
        result = result .. '.'

        if (r == 3) then
          result = result .. '/'
        end
      else
        result = result .. path_table[i]

        if (r > 0) then
          result = result .. '/'
        end
      end
    end
  end

  return '  ' .. result .. '  '
end

local bubbles_theme = {
  normal = {
    a = { fg = bg0, bg = aqua },
    b = { fg = fg1, bg = bg2 },
    c = { fg = bg0, bg = bg0 },
  },

  insert = { a = { fg = bg0, bg = yellow } },
  visual = { a = { fg = fg0, bg = bright_red } },
  replace = { a = { fg = bg0, bg = orange } },

  inactive = {
    a = { fg = fg2, bg = bg1 },
    b = { fg = fg2, bg = bg1 },
    c = { fg = bg2, bg = bg1 },
  },
}

require('lualine').setup {
  options = {
    theme = bubbles_theme,
    component_separators = '|',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      { 'mode', separator = { left = '', right = '' }, right_padding = 4 },
    },
    lualine_b = { file_path, 'branch' },
    lualine_c = { 'fileformat' },
    lualine_x = {},
    lualine_y = { 'filetype', 'progress' },
    lualine_z = {
      { 'location', separator = { left = '', right = '' }, left_padding = 4 },
    },
  },
  inactive_sections = {
    lualine_a = { file_path },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'filetype' },
  },
  tabline = {},
  extensions = {},
}
