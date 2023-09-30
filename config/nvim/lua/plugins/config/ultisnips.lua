local load_mappings = require('core.utils').load_mappings

vim.g.UltiSnipsSnippetDirectories = { vim.fn.stdpath('config') .. '/ultisnips' }
vim.g.UltiSnipsEditSplit = 'vertical'

load_mappings(require('core.mappings').ultisnips)
