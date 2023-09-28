local M = {}

local icons = require('core.icons')

local ELLIPSIS_CHAR = '…'
local MAX_LABEL_WIDTH = 25

local source_labels = {
  copilot = ' [CPT ' .. vim.trim(icons.Github) .. ']',
  nvim_lsp = ' [LSP ' .. vim.trim(icons.Stack) .. ']',
  buffer = ' [BUF ' .. vim.trim(icons.File) .. ']',
  nvim_lua = ' [LUA ' .. vim.trim(icons.Bomb) .. ']',
  ultisnips = ' [SNP ' .. vim.trim(icons.Snippet) .. ']',
  path = ' [PTH ' .. vim.trim(icons.Folder) .. ']',
}

local lspkind = (function()
  local lspkind_icons = vim.fn.map(icons, function(_, icon)
    return vim.trim(icon)
  end)

  return require('lspkind').init({
    mode = 'symbol_text',
    maxwidth = MAX_LABEL_WIDTH,
    symbol_map = lspkind_icons,
  })
end)()

M.format_selection_item = function(entry, item)
  local item_with_kind = require('lspkind').cmp_format({
    mode = 'symbol_text',
    maxwidth = MAX_LABEL_WIDTH,
    symbol_map = lspkind_icons,
  })(entry, item)

  item_with_kind.kind = require('lspkind').symbolic(item_with_kind.kind, { with_text = true })
  item_with_kind.menu = source_labels[entry.source.name] or ''
  item_with_kind.abbr = string.sub(item_with_kind.abbr, 1, item_with_kind.maxwidth)

  return item_with_kind
end

return M
