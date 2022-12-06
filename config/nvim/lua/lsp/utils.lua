--- ### lsp_utils
--
-- This module is automatically loaded by AstroNvim on during it's initialization into global variable `lsp_utils`
--
-- This module can also be manually loaded with `local updater = require("core.utils").lsp_utils`
--
-- @module core.utils.lsp_utils
-- @see core.utils
-- @copyright 2022
-- @license GNU General Public License v3.0

local lsp_utils = {}

local tbl_contains = vim.tbl_contains

lsp_utils.flags = {}

lsp_utils.servers_config = {
	sumneko_lua = {
		settings = require('lsp.servers.sumneko_lua').settings,
	},
	jsonls = {
		settings = require('lsp.servers.jsonls').settings,
	},
	eslint = {
		settings = require('lsp.servers.eslint').settings,
		on_attach = require('lsp.servers.eslint').on_attach,
	},
	tsserver = {
		on_attach = require('lsp.servers.tsserver').on_attach,
		capabilities = require('lsp.servers.tsserver').capabilities,
	},
}

lsp_utils.formatting = { format_on_save = { enabled = true } }

if type(lsp_utils.formatting.format_on_save) == 'boolean' then
	lsp_utils.formatting.format_on_save = { enabled = lsp_utils.formatting.format_on_save }
end

lsp_utils.format_opts = vim.deepcopy(lsp_utils.formatting)
lsp_utils.format_opts.disabled = nil
lsp_utils.format_opts.format_on_save = nil

-- default capabilities
lsp_utils.capabilities = vim.lsp.protocol.make_client_capabilities()
lsp_utils.capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
lsp_utils.capabilities.textDocument.completion.completionItem.snippetSupport = true
lsp_utils.capabilities.textDocument.completion.completionItem.preselectSupport = true
lsp_utils.capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
lsp_utils.capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
lsp_utils.capabilities.textDocument.completion.completionItem.deprecatedSupport = true
lsp_utils.capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
lsp_utils.capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
lsp_utils.capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = { 'documentation', 'detail', 'additionalTextEdits' },
}

lsp_utils.format_opts.filter = function(client)
	local filter = lsp_utils.formatting.filter
	local disabled = lsp_utils.formatting.disabled or {}

	-- check if client is fully disabled or filtered by function
	return not (tbl_contains(disabled, client.name) or (type(filter) == 'function' and not filter(client)))
end

return lsp_utils
