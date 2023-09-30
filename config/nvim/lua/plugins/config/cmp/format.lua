local M = {}

local icons = require('core.icons')
local utils = require('core.utils')

local ELLIPSIS_CHAR = '…'
local MAX_LABEL_WIDTH = 25

local source_labels = {
  copilot = icons.Github,
  nvim_lsp = icons.Stack,
  buffer = icons.File,
  nvim_lua = icons.Bomb,
  ultisnips = icons.Snippet,
  path = icons.Folder,
}

local menu_hl_group_name = function(source_name)
  local camel_case_source_name = utils.convert_case(source_name)
  local hl_group_name = utils.capitalize(camel_case_source_name)
  return 'CmpItemMenu' .. hl_group_name
end

M.format_selection_item = function(entry, item)
  local item_with_kind = require('lspkind').cmp_format({
    mode = 'text',
    maxwidth = MAX_LABEL_WIDTH,
  })(entry, item)

  local item_attrs = {
    menu = source_labels[entry.source.name] or '',
    menu_hl_group = menu_hl_group_name(entry.source.name),
    abbr = ' ' .. string.sub(item_with_kind.abbr, 1, item_with_kind.maxwidth),
    kind = '  ' .. item_with_kind.kind,
  }

  return vim.tbl_deep_extend('force', item_with_kind, item_attrs)
end

return M
