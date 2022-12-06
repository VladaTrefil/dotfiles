local present, null_ls = pcall(require, 'null-ls')

if not present then
	return
end

local lsp = require('lsp.config')

null_ls.setup({ on_attach = lsp.on_attach })
