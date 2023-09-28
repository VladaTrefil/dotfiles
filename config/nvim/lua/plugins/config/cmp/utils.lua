local M = {}

local cmp = require('cmp')

local MAX_INDEX_FILE_SIZE = 4000

M.get_buffers = function()
  local bufs = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    -- Don't index giant files
    if vim.api.nvim_buf_is_loaded(bufnr)
        and vim.api.nvim_buf_line_count(bufnr) < MAX_INDEX_FILE_SIZE
    then
      table.insert(bufs, bufnr)
    end
  end
  return bufs
end

M.expand_snippet = function(args)
  vim.fn['UltiSnips#Anon'](args.body)
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
