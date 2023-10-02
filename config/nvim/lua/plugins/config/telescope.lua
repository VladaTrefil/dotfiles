-- Telescope Settings:
---------------------------------------------------------------

local telescope_ok, telescope = pcall(require, 'telescope')

if not telescope_ok then
	vim.notify("Telescope lua package doesn't exist ")
	return
end

local actions = require('telescope.actions')
local mappings = require('core.mappings').telescope(actions)

local load_mappings = require('core.utils').load_mappings

FILE_IGNORE_PATTERNS = {
	'node_modules',
	'%.ttf',
	'%.eof',
	'%.woff',
	'%.woff2',
	'.git/',
}

local vimgrep_arguments = {
	'rg',
	'--hidden',
	'--color=never',
	'--no-heading',
	'--with-filename',
	'--line-number',
	'--column',
	'--smart-case',
	'--vimgrep',
	'--trim',
}

local defaults = {
	vimgrep_arguments = vimgrep_arguments,
	file_ignore_patterns = FILE_IGNORE_PATTERNS,
	set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
	prompt_prefix = '   ',
	selection_caret = ' ',
	path_display = { truncate = 3 },
	winblend = 9,
	color_devicons = true,
	selection_strategy = 'reset',
	scroll_strategy = 'limit',
	sorting_strategy = 'ascending',
	layout_strategy = 'horizontal',
	layout_config = {
		horizontal = {
			prompt_position = 'top',
			preview_width = 0.55,
			results_width = 0.8,
		},
		vertical = {
			mirror = false,
		},
		width = 0.60,
		height = 0.80,
		preview_cutoff = 120,
	},
	file_sorter = require('telescope.sorters').get_fzy_sorter,
	generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
	mappings = mappings.window,
}

local pickers = {
	find_files = {
		mappings = mappings.pickers.find_files,
	},
	buffers = {
		mappings = mappings.pickers.buffers,
		sort_mru = true,
		preview_title = false,
	},
	help_tags = {
		mappings = mappings.pickers.help_tags,
	},
}

local extensions = {
	fzf = {
		fuzzy = true, -- false will only do exact matching
		override_generic_sorter = true, -- override the generic sorter
		override_file_sorter = true, -- override the file sorter
		case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
	},
}

local M = {}

M.core_config = function()
	telescope.setup({
		defaults = defaults,
		pickers = pickers,
		extensions = extensions,
	})

	load_mappings(mappings.base)

	-- Prevent telescope from opening files in insert mode
	-- See: https://github.com/nvim-telescope/telescope.nvim/issues/2027
	vim.api.nvim_create_autocmd('WinLeave', {
		callback = function()
			if vim.bo.ft == 'TelescopePrompt' and vim.fn.mode() == 'i' then
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes('<Esc>', true, false, true),
					'i',
					false
				)
			end
		end,
	})

	-- Set telescope previewer buffer local options
	vim.api.nvim_create_autocmd('User', {
		pattern = 'TelescopePreviewerLoaded',
		callback = function()
			vim.opt_local.wrap = true
			vim.opt_local.number = true
			vim.opt_local.list = true
			vim.opt_local.tabstop = 2
			vim.opt_local.shiftwidth = 2
		end,
	})
end

M.load_extension = function(name)
	telescope.load_extension(name)
end

return M
