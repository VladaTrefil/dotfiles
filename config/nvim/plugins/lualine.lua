-- Lualine:
---------------------------------------------------------------

local bg0        = '#0B0E14'
local bg1        = '#0D1017'
local bg2        = '#151f28'
local fg0        = '#E6E1CF'
local fg1        = '#E6E1CF'
local yellow     = '#E7C547'
local orange     = '#F29718'
local aqua       = '#1f997e'
local bright_red = '#e23141'

local function file_path()
  local path = vim.fn.expand('%f')
  local _, count = path:gsub("/", "")

  if (count > 5) then
    local path_ary = vim.fn.split('/')

    -- return string.rep(".", count)
    return path
  else
    return path
  end
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
    a = { fg = fg1, bg = bg2 },
    b = { fg = fg1, bg = bg1 },
    c = { fg = bg2, bg = bg1 },
  },
}

require('lualine').setup {
  options = {
    theme = bubbles_theme,
    component_separators = '|',
    section_separators = { left = '', right = '' },
    padding = { left = 1, right = 1 }
  },
  sections = {
    lualine_a = {
      { 'mode', separator = { left = '', right = '' } },
    },
    lualine_b = {
      { file_path, padding = { left = 2, right = 2 } },
      { 'branch', padding = { left = 2, right = 2 } },
    },
    lualine_c = { 'fileformat' },
    lualine_x = {},
    lualine_y = {
      { 'filetype' },
      { 'progress' }
    },
    lualine_z = {
      { 'location', separator = { left = '', right = '' }, padding = { left = 0, right = 1 } },
    },
  },
  inactive_sections = {
    lualine_a = {
      { file_path, separator = { left = '', right = '' } }
    },
    -- lualine_b = {},
    -- lualine_c = {},
    -- lualine_x = {},
    -- lualine_y = {},
    lualine_z = {
      { 'filetype', padding = { right = 2, left = 2 } }
    },
  },
  tabline = {},
  extensions = {},
}
