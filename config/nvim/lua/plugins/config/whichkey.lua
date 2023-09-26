local whichkey_ok, whichkey = pcall(require, 'which-key')

if not whichkey_ok then
  return
end

vim.o.timeout = true
vim.o.timeoutlen = 300

whichkey.setup({})
