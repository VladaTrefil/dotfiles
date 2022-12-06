-- ASCII: https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=Larry%203D

vim.defer_fn(function()
	pcall(require, 'impatient')
end, 0)

require('core.options')

vim.cmd('source $XDG_CONFIG_HOME/nvim/legacy/script.vim')
vim.cmd('source $XDG_CONFIG_HOME/nvim/legacy/palette.vim')
vim.cmd('source $XDG_CONFIG_HOME/nvim/legacy/theme.vim')

require('plugins')

require('core.utils').create_global_functions()

require('core.utils').load_mappings()
