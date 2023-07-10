local present, lualine = pcall(require, 'lualine')

if not present then
  return
end

local palette = {}

palette = {
  bg0 = '#0B0E14',
  bg1 = '#0D1017',
  bg2 = '#151f28',
  fg0 = '#E6E1CF',
  fg1 = '#E6E1CF',
  yellow = '#E7C547',
  orange = '#F29718',
  aqua = '#1f997e',
  bright_red = '#e23141',
}

local function file_path()
  local path = vim.fn.expand('%f')
  local _, count = path:gsub('/', '')

  if count > 5 then
    local path_ary = vim.fn.split('/')

    -- return string.rep(".", count)
    return path
  else
    return path
  end
end

local bubbles_theme = {
  normal = {
    a = { fg = palette.bg0, bg = palette.aqua },
    b = { fg = palette.fg1, bg = palette.bg2 },
    c = { fg = palette.bg0, bg = palette.bg0 },
  },

  insert = { a = { fg = palette.bg0, bg = palette.yellow } },
  visual = { a = { fg = palette.fg0, bg = palette.bright_red } },
  replace = { a = { fg = palette.bg0, bg = palette.orange } },

  inactive = {
    a = { fg = palette.fg1, bg = palette.bg2 },
    b = { fg = palette.fg1, bg = palette.bg0 },
    c = { fg = palette.bg2, bg = palette.bg0 },
  },
}

lualine.setup({
  options = {
    theme = bubbles_theme,
    component_separators = '|',
    section_separators = { left = '', right = '' },
    padding = { left = 1, right = 1 },
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
      { 'progress' },
    },
    lualine_z = {
      { 'location', separator = { left = '', right = '' }, padding = { left = 0, right = 1 } },
    },
  },
  inactive_sections = {
    lualine_a = {
      { file_path, separator = { left = '', right = '' } },
    },
    -- lualine_b = {},
    -- lualine_c = {},
    -- lualine_x = {},
    -- lualine_y = {},
    lualine_z = {
      { 'filetype', padding = { right = 2, left = 2 } },
    },
  },
  tabline = {},
  extensions = {},
})
