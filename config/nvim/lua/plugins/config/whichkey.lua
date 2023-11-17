local whichkey_ok, whichkey = pcall(require, 'which-key')

if not whichkey_ok then
	return
end

vim.opt.timeout = true
vim.opt.timeoutlen = 0

whichkey.setup({})
