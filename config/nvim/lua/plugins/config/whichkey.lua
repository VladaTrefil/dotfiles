local whichkey_ok, whichkey = pcall(require, 'which-key')

if not whichkey_ok then
	return
end

whichkey.setup({})
