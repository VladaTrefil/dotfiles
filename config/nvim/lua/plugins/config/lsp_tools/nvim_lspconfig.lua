local mason_lspconfig_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
local lsp = require('lsp')

require('mason').setup()

if not mason_lspconfig_ok then
	return
end

vim.cmd('silent! do FileType')

mason_lspconfig.setup({
	ensure_installed = {
		'eslint',
		'cssls',
		'yamlls',
		'lua_ls',
		'pylsp',
		'beautysh',

		-- TODO: ensure installed non-lsp
		-- 'prettier',
		-- 'codespell',
		-- 'stylua',
		-- 'tsserver',
	},
	automatic_installation = true,
})

mason_lspconfig.setup_handlers({
	function(server)
		lsp.setup(server)
	end,
})

-- vim.lsp.handlers['textDocument/hover'] =
-- 	vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
-- vim.lsp.handlers['textDocument/signatureHelp'] =
-- 	vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
-- vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
-- 	local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
-- 	local bufnr = vim.api.nvim_get_current_buf()
--
-- 	vim.diagnostic.reset(ns, bufnr)
--
-- 	return true
-- end
