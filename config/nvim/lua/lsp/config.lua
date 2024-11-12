local M = {}

local icons = require('core.icons')

M.servers_config = {
	lua_ls = require('lsp.servers.lua_ls'),
	jsonls = require('lsp.servers.jsonls'),
	eslint = require('lsp.servers.eslint'),
	tsserver = require('lsp.servers.tsserver'),
	-- cssls = require('lsp.servers.css_ls'),
	rubocop = require('lsp.servers.rubocop'),
	pylsp = require('lsp.servers.pylsp'),
}

M.disabled_servers = { 'rubocop', 'tsserver', 'eslint' }

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
	Error = icons.Error:gsub('%s$', ''),
	Warn = icons.Warning:gsub('%s$', ''),
	Hint = icons.Hint:gsub('%s$', ''),
	Info = icons.Info:gsub('%s$', ''),
}

M.diagnostic_config = {
	signs = {
		priority = 10,
		text = {
			[vim.diagnostic.severity.ERROR] = icons.Error:gsub('%s$', ''),
			[vim.diagnostic.severity.WARN] = icons.Warning:gsub('%s$', ''),
			[vim.diagnostic.severity.HINT] = icons.Hint:gsub('%s$', ''),
			[vim.diagnostic.severity.INFO] = icons.Info:gsub('%s$', ''),
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
			[vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
			[vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
			[vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
		},
	},
	underline = {
		severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
	},
	update_in_insert = false,
	severity_sort = true,
	virtual_text = {
		severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
		spacing = 1,
	},
	float = {
		source = 'always', -- Or "if_many"
	},
}

M.flags = {}

return M
