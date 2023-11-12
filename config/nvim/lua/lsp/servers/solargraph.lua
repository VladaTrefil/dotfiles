local util = require('lspconfig.util')

return {
  cmd = { 'solargraph', 'stdio' },
  settings = {
    Solargraph = {
      diagnostics = true,
      root_dir = util.root_pattern('Gemfile', '.git')(fname),
    },
  },
}
