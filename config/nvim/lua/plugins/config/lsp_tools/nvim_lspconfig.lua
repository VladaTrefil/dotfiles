local lsp = require('lsp')

require('mason').setup()

local mason_lspconfig_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')

mason_lspconfig.setup({
	ensure_installed = {
		-- 'prettier',
		'tsserver',
		'eslint',
		'cssls',
		-- 'codespell',
		-- 'stylua',
		'yamlls',
		'lua_ls',
	},
	automatic_installation = true,
})

mason_lspconfig.setup_handlers({
	function(server)
		lsp.setup(server)
	end,
})

-- vim.lsp.handlers['textDocument/hover'] =
-- vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
-- vim.lsp.handlers['textDocument/signatureHelp'] =
-- vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
	local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
	local bufnr = vim.api.nvim_get_current_buf()

	vim.diagnostic.reset(ns, bufnr)

	return true
end

if mason_lspconfig_ok then
	vim.tbl_map(lsp.setup, {})
	vim.cmd('silent! do FileType')
end
