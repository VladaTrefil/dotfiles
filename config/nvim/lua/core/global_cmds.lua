local utils = require('core.utils')

function _G.ReloadConfig()
  for name, _ in pairs(package.loaded) do
    if name:match('^user') and not name:match('nvim-tree') then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)

  vim.notify('Nvim configuration reloaded!', vim.log.levels.INFO)
end

function _G.closeBuffer()
  local tab_number = vim.fn.tabpagenr()
  local tab_pages = vim.fn.tabpagebuflist(tab_number)
  local tab_pages_len = vim.fn.len(tab_pages)

  print(tab_pages, tab_pages_len, tab_number)
  -- close buffer window if last in tab
  return tab_pages_len > 1
end

function _G.isCursorInsideNewBlock()
  return utils.is_cursor_inside_new_block()
end
