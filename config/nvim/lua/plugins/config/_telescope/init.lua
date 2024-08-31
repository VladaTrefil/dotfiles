local telescope_ok, telescope = pcall(require, 'telescope')

if not telescope_ok then
	vim.notify("Telescope lua package doesn't exist")
	return
end

VIMGREP_ARGUMENTS = {
	'rg',
	'--threads=1',
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

FILE_IGNORE_PATTERNS = {
	'node_modules',
	'vendor',
	'%.ttf',
	'%.eof',
	'%.woff',
	'%.woff2',
	'.git/',
	'react.js',
}

local utils = require('core.utils')
local icons = require('core.icons')

local mappings = require('plugins.config._telescope.mappings')
local theme = require('plugins.config._telescope.theme')

local pickers = {
	find_files = {
		prompt_title = 'Find Files ',
		mappings = mappings.pickers.find_files,
	},
	live_grep = {
		prompt_title = 'Live grep ',
	},
	buffers = {
		prompt_title = 'Buffers ',
		mappings = mappings.pickers.buffers,
		sort_mru = true,
		preview_title = false,
		theme = 'dropdown',
	},
	help_tags = {
		prompt_title = 'Help tags ',
		mappings = mappings.pickers.help_tags,
	},
	git_status = {
		devicons = false,
		git_icons = {
			added = icons.Plus,
			changed = icons.Change,
			copied = icons.Copy,
			delete = icons.Minus,
			renamed = icons.Character,
			untracked = icons.PlusSquare,
		},
	},
	-- TODO: Picker with theme=cursor for copy history selection and past action
}

local lga_actions = require('telescope-live-grep-args.actions')
local extensions = {
	fzf = {
		fuzzy = true, -- false will only do exact matching
		override_generic_sorter = true, -- override the generic sorter
		override_file_sorter = true, -- override the file sorter
		case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
	},
	live_grep_args = {
		prompt_title = 'Search with ripgrep ',
		auto_quoting = true, -- enable/disable auto-quoting
		mappings = { -- extend mappings
			i = {
				['<C-f>'] = lga_actions.quote_prompt(),
				['<C-g>'] = lga_actions.quote_prompt({ postfix = ' --iglob ' }),
			},
		},
	},
}

require('plugins.config._telescope.utils').create_autocmds()

telescope.setup({
	defaults = {
		vimgrep_arguments = VIMGREP_ARGUMENTS,
		file_ignore_patterns = FILE_IGNORE_PATTERNS,
		set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
		prompt_prefix = '   ',
		selection_caret = ' ',
		multi_icon = icons.Plus .. ' ',
		path_display = { truncate = 3 },
		winblend = 9,
		color_devicons = true,
		selection_strategy = 'reset',
		scroll_strategy = 'limit',
		sorting_strategy = 'ascending',
		layout_strategy = 'horizontal',
		layout_config = {
			prompt_position = 'top',
			width = 0.60,
			height = 0.80,
			-- preview_cutoff = 120,
			vertical = {
				mirror = true,
			},
			horizontal = {
				preview_width = 0.55,
				results_width = 0.8,
			},
		},
		file_sorter = require('telescope.sorters').get_fzy_sorter,
		generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
		mappings = mappings.window,
	},
	pickers = pickers,
	extensions = extensions,
})

utils.load_mappings(mappings.base)
utils.set_highlights(theme)

require('plugins.config._telescope.utils').load_extension('live_grep_args')
