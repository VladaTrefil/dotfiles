local lsp = {}

local user_config = require('lsp.config')
local on_attach_func = require('lsp.on_attach')
local lspconfig = require('lspconfig')
local sign_handler = require('lsp.sign_handler')

local default_capabilities = vim.lsp.protocol.make_client_capabilities()
local extend = vim.tbl_deep_extend

-- Register a handler for displaying diagnostic signs
sign_handler.register()

--- Helper function to set up a given server with the Neovim LSP client
-- @param server the name of the server to be setup
lsp.setup = function(server)
	if vim.tbl_contains(user_config.disabled_servers, server) then
		return
	end

	lsp.setup_server(server)
	vim.diagnostic.config(user_config.diagnostic_config)

	for type, icon in pairs(user_config.signs) do
		local hl = 'DiagnosticSign' .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end
end

--- Get the server settings for a given language server to be provided to the server's `setup()` call
-- @param  server_name the name of the server
-- @return the table of lsp_utils options used when setting up the given language server
lsp.setup_server = function(server_name)
	local server = lspconfig[server_name]
	local user_server_config = user_config.servers_config[server_name] or {}

	local capabilities = extend(
		'force',
		default_capabilities,
		user_config.capabilities or {},
		server.capabilities or {},
		user_server_config.capabilities or {}
	)

	local settings = extend('force', user_config.settings or {}, user_server_config.settings or {})

	local flags = extend('force', user_config.flags, server.flags or {})

	local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
	if cmp_nvim_lsp_ok then
		capabilities = extend('force', capabilities, cmp_nvim_lsp.default_capabilities())
	end

	local opts = {
		settings = settings,
		capabilities = capabilities,
		flags = flags,
		on_attach = function(client, bufnr)
			if not client then
				return
			end

			if user_server_config.on_attach then
				user_server_config.on_attach()
			end

			lsp.on_attach(client, bufnr)
		end,
	}

	opts = extend('force', user_server_config, opts)
	lspconfig[server_name].setup(opts)
end

-- @param client - the LSP client details when attaching
-- @param bufnr - the number of the buffer that the LSP client is attaching to
lsp.on_attach = function(client, bufnr)
	local capabilities = client.server_capabilities

	on_attach_func.highlighting(capabilities, bufnr)
	on_attach_func.mappings(capabilities, bufnr)
end

return lsp
