-- ASCII: https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=Larry%203D

vim.defer_fn(function()
  pcall(require, 'impatient')
end, 0)

require('theme')

require('core.options')

require('core.global_cmds')

vim.cmd('source $XDG_CONFIG_HOME/nvim/legacy/script.vim')

require('plugins')

local base_mappings = require('core.mappings').general
require('core.utils').load_mappings(base_mappings)
