local M = {}

local icons = require('core.icons')

M.servers_config = {
	lua_ls = require('lsp.servers.lua_ls'),
	jsonls = require('lsp.servers.jsonls'),
	eslint = require('lsp.servers.eslint'),
	tsserver = require('lsp.servers.tsserver'),
	cssls = require('lsp.servers.css_ls'),
	rubocop = require('lsp.servers.rubocop'),
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

M.signs = {
	Error = icons.Error:gsub('%s', ''),
	Warn = icons.Warning:gsub('%s', ''),
	Hint = icons.Hint:gsub('%s', ''),
	Info = icons.Info:gsub('%s', ''),
}

M.diagnostic_config = {
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = false,
	virtual_text = true,
	float = {
		source = 'always', -- Or "if_many"
	},
}

M.flags = {}

return M
