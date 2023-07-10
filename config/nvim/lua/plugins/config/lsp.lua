local lsp = require('lsp.config')
local utils = require('core.utils')

local setup_null_ls = function()
  local present, null_ls = pcall(require, 'null-ls')

  if not present then
    return
  end

  null_ls.setup({ on_attach = lsp.on_attach })
end

local setup_mason = function()
  local present, mason = pcall(require, 'mason')

  if not present then
    return
  end

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

local setup_mason_null_ls = function()
	local present_null_ls, mason_null_ls = pcall(require, 'mason-null-ls')

	if not present_null_ls then
		return
	end

	mason_null_ls.setup({ automatic_setup = true })
end

local setup_mason_lspconfig = function()
	local mason_lspconfig = require('mason-lspconfig')

	mason_lspconfig.setup({
    ensure_installed = {},
    automatic_installation = true,
  })

	mason_lspconfig.setup_handlers({
		function(server)
			lsp.setup(server)
		end,
	})
end

local setup_nvim_lspconfig = function()
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

  vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.reset(ns, bufnr)
    return true
  end

  local setup_servers = function()
    vim.tbl_map(lsp.setup, {})
    vim.cmd('silent! do FileType')
  end

  if utils.is_available('mason-lspconfig') then
    setup_servers()
  end
end

setup_null_ls()
setup_mason()
setup_mason_null_ls()
setup_mason_lspconfig()
setup_nvim_lspconfig()
