local lsp = {}

local lsp_utils = require('lsp.utils')
local lspconfig = require('lspconfig')

local tbl_isempty = vim.tbl_isempty
local tbl_contains = vim.tbl_contains

local user_registration = nil
local skip_setup = {}

--- Get the server settings for a given language server to be provided to the server's `setup()` call
-- @param  server_name the name of the server
-- @return the table of lsp_utils options used when setting up the given language server
lsp.server_settings = function(server_name)
	local server = lspconfig[server_name]

	local settings = {}
	local on_attach = nil

	local capabilities = vim.tbl_deep_extend('force', lsp_utils.capabilities, server.capabilities or {})
	local flags = vim.tbl_deep_extend('force', lsp_utils.flags, server.flags or {})

	if tbl_contains(vim.tbl_keys(lsp_utils.servers_config), server_name) then
		config = lsp_utils.servers_config[server_name]
		config_keys = vim.tbl_keys(config)

		if tbl_contains(config_keys, 'settings') then
			settings = config.settings
		end

		if tbl_contains(config_keys, 'on_attach') then
			on_attach = config.on_attach
		end

		if tbl_contains(config_keys, 'capabilities') then
			capabilities = vim.tbl_deep_extend('force', config.capabilities, capabilities)
		end
	end

	local opts = {
		settings = settings,
		capabilities = capabilities,
	}

	opts.on_attach = function(client, bufnr)
		if on_attach then
			on_attach()
		end

		lsp.on_attach(client, bufnr)
	end

	return opts
end

--- Helper function to set up a given server with the Neovim LSP client
-- @param server the name of the server to be setup
lsp.setup = function(server)
	-- skip server
	if tbl_contains(skip_setup, server) then
		return
	end

	local opts = lsp.server_settings(server)

	if type(user_registration) == 'function' then
		user_registration(server, opts)
	else
		lspconfig[server].setup(opts)
	end
end

-- @param client the LSP client details when attaching
-- @param bufnr the number of the buffer that the LSP client is attaching to
lsp.on_attach = function(client, bufnr)
	local capabilities = client.server_capabilities

	if capabilities.documentFormattingProvider then
		vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
			vim.lsp.buf.format(lsp_utils.format_opts)
		end, { desc = 'Format file with LSP' })

		local autoformat = lsp_utils.formatting.format_on_save
		local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')

		local allow_filetypes = autoformat.allow_filetypes or {}
		local allow_autoformat = tbl_isempty(allow_filetypes) or tbl_contains(allow_filetypes, filetype)

		local ignore_filetypes = autoformat.ignore_filetypes or {}
		local ignore_autoformat = not tbl_isempty(ignore_filetypes) and tbl_contains(ignore_filetypes, filetype)

		if autoformat.enabled and allow_autoformat and not ignore_autoformat then
			local autocmd_group = 'auto_format_' .. bufnr

			vim.api.nvim_create_augroup(autocmd_group, { clear = true })

			vim.api.nvim_create_autocmd('BufWritePre', {
				group = autocmd_group,
				buffer = bufnr,
				desc = 'Auto format buffer ' .. bufnr .. ' before save',

				callback = function()
					if vim.g.autoformat_enabled then
						local format_opts = vim.tbl_deep_extend('force', lsp_utils.format_opts), { bufnr = bufnr }

						vim.lsp.buf.format(format_opts)
					end
				end,
			})
		end
	end

	if capabilities.documentHighlightProvider then
		local highlight_name = vim.fn.printf('lsp_document_highlight_%d', bufnr)
		vim.api.nvim_create_augroup(highlight_name, {})
		vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
			group = highlight_name,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.document_highlight()
			end,
		})
		vim.api.nvim_create_autocmd('CursorMoved', {
			group = highlight_name,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.clear_references()
			end,
		})
	end

	-- ────────────────────────────────────────────────────────────────────────────────────────────────────
	-- Mappings: {{{

	-- local lsp_mappings = {
	-- 	n = {
	-- 		['<leader>ld'] = {
	-- 			function()
	-- 				vim.diagnostic.open_float()
	-- 			end,
	-- 			'Hover diagnostics',
	-- 		},
	-- 		['[d'] = {
	-- 			function()
	-- 				vim.diagnostic.goto_prev()
	-- 			end,
	-- 			'Previous diagnostic',
	-- 		},
	-- 		[']d'] = {
	-- 			function()
	-- 				vim.diagnostic.goto_next()
	-- 			end,
	-- 			'Next diagnostic',
	-- 		},
	-- 		['gl'] = {
	-- 			function()
	-- 				vim.diagnostic.open_float()
	-- 			end,
	-- 			'Hover diagnostics',
	-- 		},
	-- 	},
	-- 	v = {},
	-- }
	--
	-- if capabilities.codeActionProvider then
	-- 	lsp_mappings.n['<leader>la'] = {
	-- 		function()
	-- 			vim.lsp.buf.code_action()
	-- 		end,
	-- 		desc = 'LSP code action',
	-- 	}
	-- 	lsp_mappings.v['<leader>la'] = lsp_mappings.n['<leader>la']
	-- end
	--
	-- if capabilities.codeLensProvider then
	-- 	lsp_mappings.n['<leader>ll'] = {
	-- 		function()
	-- 			vim.lsp.codelens.refresh()
	-- 		end,
	-- 		desc = 'LSP codelens refresh',
	-- 	}
	-- 	lsp_mappings.n['<leader>lL'] = {
	-- 		function()
	-- 			vim.lsp.codelens.run()
	-- 		end,
	-- 		desc = 'LSP codelens run',
	-- 	}
	-- end
	--
	-- if capabilities.declarationProvider then
	-- 	lsp_mappings.n['gD'] = {
	-- 		function()
	-- 			vim.lsp.buf.declaration()
	-- 		end,
	-- 		desc = 'Declaration of current symbol',
	-- 	}
	-- end
	--
	-- if capabilities.definitionProvider then
	-- 	lsp_mappings.n['gd'] = {
	-- 		function()
	-- 			vim.lsp.buf.definition()
	-- 		end,
	-- 		desc = 'Show the definition of current symbol',
	-- 	}
	-- end

	-- if capabilities.hoverProvider then
	-- 	lsp_mappings.n['K'] = {
	-- 		function()
	-- 			vim.lsp.buf.hover()
	-- 		end,
	-- 		desc = 'Hover symbol details',
	-- 	}
	-- end
	--
	-- if capabilities.implementationProvider then
	-- 	lsp_mappings.n['gI'] = {
	-- 		function()
	-- 			vim.lsp.buf.implementation()
	-- 		end,
	-- 		desc = 'Implementation of current symbol',
	-- 	}
	-- end
	--
	-- if capabilities.referencesProvider then
	-- 	lsp_mappings.n['gr'] = {
	-- 		function()
	-- 			vim.lsp.buf.references()
	-- 		end,
	-- 		desc = 'References of current symbol',
	-- 	}
	-- end
	--
	-- if capabilities.renameProvider then
	-- 	lsp_mappings.n['<leader>lr'] = {
	-- 		function()
	-- 			vim.lsp.buf.rename()
	-- 		end,
	-- 		desc = 'Rename current symbol',
	-- 	}
	-- end
	--
	-- if capabilities.signatureHelpProvider then
	-- 	lsp_mappings.n['<leader>lh'] = {
	-- 		function()
	-- 			vim.lsp.buf.signature_help()
	-- 		end,
	-- 		desc = 'Signature help',
	-- 	}
	-- end
	--
	-- if capabilities.typeDefinitionProvider then
	-- 	lsp_mappings.n['gT'] = {
	-- 		function()
	-- 			vim.lsp.buf.type_definition()
	-- 		end,
	-- 		desc = 'Definition of current type',
	-- 	}
	-- end

	if capabilities.documentFormattingProvider then
		-- lsp_mappings.n['<leader>lf'] = {
		-- 	function()
		-- 		vim.lsp.buf.format(lsp.format_opts)
		-- 	end,
		-- 	desc = 'Format code',
		-- }
		--
		-- lsp_mappings.v['<leader>lf'] = lsp_mappings.n['<leader>lf']
	end

	-- astronvim.set_mappings(user_plugin_opts('lsp.mappings', lsp_mappings), { buffer = bufnr })

	-- if not vim.tbl_isempty(lsp_mappings.v) then
	-- 	astronvim.which_key_register({ v = { ['<leader>'] = { l = { name = 'LSP' } } } }, { buffer = bufnr })
	-- end

	-- }}}
	-- ────────────────────────────────────────────────────────────────────────────────────────────────────
end

return lsp