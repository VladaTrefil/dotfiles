local M = {}

M.servers_config = {
	lua_ls = require('lsp.servers.lua_ls'),
	jsonls = require('lsp.servers.jsonls'),
	eslint = require('lsp.servers.eslint'),
	tsserver = require('lsp.servers.tsserver'),
	-- solargraph = require('lsp.servers.solargraph'),
	-- rubocop = require('lsp.servers.rubocop'),
}

M.capabilities = {
	textDocument = {
		completion = {
			completionItem = {
				documentationFormat = { 'markdown', 'plaintext' },
				snippetSupport = true,
				preselectSupport = true,
				insertReplaceSupport = true,
				labelDetailsSupport = true,
				deprecatedSupport = true,
				commitCharactersSupport = true,
				tagSupport = {
					valueSet = { 1 },
				},
				resolveSupport = {
					properties = { 'documentation', 'detail', 'additionalTextEdits' },
				},
			},
		},
	},
}

M.signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }

M.diagnotic_config = {
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = false,
	virtual_text = {
		source = 'always', -- Or "if_many"
	},
	float = {
		source = 'always', -- Or "if_many"
	},
}

M.flags = {}

return M
