local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')

if not gitsigns_ok then
	vim.notify('gitsigns not found', vim.log.levels.ERROR)
	return
end

local icons = require('core.icons')
local utils = require('core.utils')

local theme = require('plugins.config._gitsigns.theme')

utils.set_highlights(theme)

gitsigns.setup({
	signs = {
		add = { text = icons.PipeDashed },
		change = { text = icons.PipeDashed },
		delete = { text = icons.PipeDashed },
		topdelete = { text = icons.PipeDashed },
		changedelete = { text = icons.PipeDashed },
		untracked = { text = icons.PipeDashed },
	},
	sign_priority = 6,
	attach_to_untracked = true,
})
