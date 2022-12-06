local lsp = require('lsp.config')

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

local setup_servers = function()
	vim.tbl_map(lsp.setup, {})
	vim.cmd('silent! do FileType')
end

local present, mason = pcall(require, 'mason-lspconfig.nvim')

if present then
	vim.api.nvim_create_autocmd('User', {
		pattern = 'CustomLspSetup',
		once = true,
		callback = setup_servers,
	})
else
	setup_servers()
end
