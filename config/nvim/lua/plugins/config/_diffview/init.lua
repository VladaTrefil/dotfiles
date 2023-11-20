local diffview_ok, _ = pcall(require, 'diffview')

if not diffview_ok then
	vim.notify('diffview not found', vim.log.levels.ERROR)
	return
end

local actions = require('diffview.actions')
local utils = require('core.utils')

local highlights = require('plugins.config._diffview.theme')
local mappings = {
	n = {
		['<leader>gd'] = { '<cmd> DiffviewOpen <CR>', 'Open Diffview layout' },
	},
}

utils.set_highlights(highlights)
utils.load_mappings(mappings)

require('diffview').setup({
	diff_binaries = false, -- Show diffs for binaries
	icons = { -- Only applies when use_icons is true.
		folder_closed = '',
		folder_open = '',
	},
	signs = {
		fold_closed = '',
		fold_open = '',
	},
	file_panel = {
		win_config = {
			position = 'left',
			width = 35,
		},
	},
	key_bindings = {
		-- The `view` bindings are active in the diff buffers, only when the current
		-- tabpage is a Diffview.
		view = {
			['<tab>'] = actions.select_next_entry, -- Open the diff for the next file
			['<s-tab>'] = actions.select_prev_entry, -- Open the diff for the previous file
			['<leader>e'] = actions.focus_files, -- Bring focus to the files panel
			['<leader>b'] = actions.toggle_files, -- Toggle the files panel.
		},
		file_panel = {
			['j'] = actions.next_entry, -- Bring the cursor to the next file entry
			['<down>'] = actions.next_entry,
			['k'] = actions.prev_entry, -- Bring the cursor to the previous file entry.
			['<up>'] = actions.prev_entry,
			['<cr>'] = actions.select_entry, -- Open the diff for the selected entry.
			['o'] = actions.select_entry,
			['R'] = actions.refresh_files, -- Update stats and entries in the file list.
			['<tab>'] = actions.select_next_entry,
			['<s-tab>'] = actions.select_prev_entry,
			['<leader>e'] = actions.focus_files,
			['<leader>b'] = actions.toggle_files,
		},
	},
})
