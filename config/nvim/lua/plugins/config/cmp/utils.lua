local M = {}

local ELLIPSIS_CHAR = '…'
local MAX_LABEL_WIDTH = 25

local cmp = require('cmp')

M.format_selection_item = function(_, item)
  local content = item.abbr

  local abbr = (' '):rep(MAX_LABEL_WIDTH - #content)

  if #content > MAX_LABEL_WIDTH then
    item.abbr = vim.fn.strcharpart(content, 0, MAX_LABEL_WIDTH) .. ELLIPSIS_CHAR
  else
    item.abbr = content .. abbr
  end

  return item
end

M.get_buffers = function()
  local bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    bufs[vim.api.nvim_win_get_buf(win)] = true
  end
  return vim.tbl_keys(bufs)
end

M.expand_snippet = function(args)
  -- require('core.utils').notify(args)
  vim.fn['UltiSnips#Anon'](args.body)
end

M.has_words_before = function()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  line = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]

  return col ~= 0 and line:sub(col, col):match('%s') == nil
end

M.on_confirm = function(fallback)
  if cmp.visible() then
    cmp.confirm({ select = true })
  elseif vim.fn['UltiSnips#CanJumpForwards']() ~= 0 then
    vim.fn['UltiSnips#JumpForwards']()
  else
    fallback()
  end
end

M.on_confirm_inverse = function(fallback)
  if vim.fn['UltiSnips#CanJumpBackwards']() ~= 0 then
    vim.fn['UltiSnips#JumpBackwards']()
  else
    fallback()
  end
end

return M
