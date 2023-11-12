local M = {}

local util = require('lspconfig.util')

-- Error executing lua callback: /home/vlada/.config/nvim/lua/lsp/servers/tsserver.lua:42: attempt to index local 'client' (a nil value)
-- stack traceback:
-- /home/vlada/.config/nvim/lua/lsp/servers/tsserver.lua:42: in function 'on_attach'
-- ...ck/packer/start/nvim-lspconfig/lua/lspconfig/configs.lua:236: in function <...ck/packer/start/nvim-lspconfig/lua/lspconfig/configs.lua:235>
-- Error detected while processing BufEnter Autocommands for "<buffer=14>":
-- Error executing lua callback: /home/vlada/.config/nvim/lua/lsp/servers/eslint.lua:58: attempt to index local 'client' (a nil value)

local root_file = {
  '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.yaml',
  '.eslintrc.yml',
  '.eslintrc.json',
  'eslint.config.js',
  '.git',
}

M.settings = {
  codeAction = {
    disableRuleComment = {
      enable = true,
      location = 'separateLine',
    },
    showDocumentation = {
      enable = true,
    },
  },
  codeActionOnSave = {
    enable = false,
    mode = 'all',
  },
  format = true,
  nodePath = '',
  onIgnoredFiles = 'off',
  packageManager = 'npm',
  quiet = false,
  rulesCustomizations = {},
  run = 'onType',
  useESLintClass = false,
  validate = 'on',
  workingDirectory = {
    mode = 'location',
  },
}

M.filetypes = {
  'javascript',
  'javascriptreact',
  'javascript.jsx',
  'typescript',
  'typescriptreact',
  'typescript.tsx',
}

M.cmd = { 'vscode-eslint-language-server', '--stdio' }

M.root_dir = function(fname)
  return util.root_pattern((unpack or table.unpack)(root_file))(fname)
end

M.on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = true

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
end

return M
