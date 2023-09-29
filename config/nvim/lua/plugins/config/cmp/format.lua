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
  return utils.capitalize(camel_case_source_name)
end

M.format_selection_item = function(entry, item)
  local item_with_kind = require('lspkind').cmp_format({
    mode = 'text',
    maxwidth = MAX_LABEL_WIDTH,
  })(entry, item)

  item_with_kind.menu = source_labels[entry.source.name] or ''
  item_with_kind.menu_hl_group = 'CmpItemMenu' .. menu_hl_group_name(entry.source.name)
  item_with_kind.abbr = ' ' .. string.sub(item_with_kind.abbr, 1, item_with_kind.maxwidth)
  item_with_kind.kind = '  ' .. item_with_kind.kind

  return item_with_kind
end

return M
