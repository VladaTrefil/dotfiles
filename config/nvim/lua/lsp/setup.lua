-- Setup installer & lsp configs
local typescript_ok, typescript = pcall(require, 'typescript')
local lsp_installer_ok, lsp_installer = pcall(require, 'nvim-lsp-installer')

if not lsp_installer_ok then
  return
end

lsp_installer.setup({
  ensure_installed = { 'bashls', 'cssls', 'eslint', 'jsonls', 'sumneko_lua', 'tsserver', 'solargraph', 'vimls' },
  automatic_installation = true,
})

local lspconfig = require('lspconfig')

local handlers = {
  ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
  ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
}

-- args: client, bufnr
local function on_attach()
  vim.cmd('autocmd! BufWritePre *.lua lua vim.lsp.buf.formatting_sync(nil, 1000)')

end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')

if cmp_nvim_lsp_ok then
  capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
end


local tsserver_config = require('lsp.servers.tsserver')
local eslint_config = require('lsp.servers.eslint')
local jsonls_config = require('lsp.servers.jsonls')
local lua_config = require('lsp.servers.sumneko_lua')

-- It enables tsserver automatically so no need to call lspconfig.tsserver.setup
if typescript_ok then
  typescript.setup({
    disable_commands = false, -- prevent the plugin from creating Vim commands
    disable_formatting = false, -- disable tsserver's formatting capabilities
    debug = false, -- enable debug logging for commands
    server = {
      capabilities = tsserver_config.capabilities,
      handlers = handlers,
      on_attach = tsserver_config.on_attach,
    },
  })
end

lspconfig.eslint.setup({
  capabilities = capabilities,
  handlers = handlers,
  on_attach = eslint_config.on_attach,
  settings = eslint_config.settings,
})

lspconfig.jsonls.setup({
  capabilities = capabilities,
  handlers = handlers,
  on_attach = on_attach,
  settings = jsonls_config.settings,
})

lspconfig.sumneko_lua.setup({
  handlers = handlers,
  on_attach = on_attach,
  settings = lua_config.settings,
})

for _, server in ipairs { "bashls", "vimls", "solargraph", "cssls" } do
  lspconfig[server].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    handlers = handlers,
  }
end
