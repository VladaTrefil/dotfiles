local M = {}

local present, mason = pcall(require, 'mason')

if not present then
	return
end

M.setup_core = function()
	vim.tbl_map(function(plugin)
		pcall(require, plugin)
	end, { 'lspconfig', 'null-ls' })

	mason.setup({
		ui = {
			icons = {
				package_installed = '✓',
				package_uninstalled = '✗',
				package_pending = '➜',
			},
		},
	})
end

M.setup_null_ls = function()
	local present_null_ls, mason_null_ls = pcall(require, 'mason-null-ls')

	if not present_null_ls then
		return
	end

	mason_null_ls.setup({ automatic_setup = true })
	mason_null_ls.setup_handlers({})
end

M.setup_lspconfig = function()
	local mason_lspconfig = require('mason-lspconfig')
	local lsp = require('lsp.config')
	local utils = require('core.utils')

	mason_lspconfig.setup()

	mason_lspconfig.setup_handlers({
		function(server)
			lsp.setup(server)
		end,
	})

	utils.trigger_event('LspSetup')
end

return M
