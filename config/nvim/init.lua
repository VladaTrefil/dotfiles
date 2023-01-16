-- ASCII: https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=Larry%203D

vim.defer_fn(function()
	pcall(require, 'impatient')
end, 0)

require('theme')

require('core.options')

vim.cmd('source $XDG_CONFIG_HOME/nvim/legacy/script.vim')

require('plugins')

require('core.utils').create_global_functions()

require('core.utils').load_mappings()
