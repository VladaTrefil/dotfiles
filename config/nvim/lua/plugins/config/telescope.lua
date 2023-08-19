-- Telescope Settings:
---------------------------------------------------------------

local present, telescope = pcall(require, 'telescope')

if not present then
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
  '.git/'
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
  buffers = {
    mappings = mappings.pickers.buffers,
    sort_mru = true,
    preview_title = false,
  },
  help_tags = {
    mappings = mappings.pickers.help_tags,
  },
  -- help_tags = {},
  -- man_pages = {},
  -- command_history = {},
  -- reloader = {},
  -- keymaps = {},
  --
  -- highlights = {},
  -- autocommands = {},
  -- vim_options = {},
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
    extensions = extensions
  })

  load_mappings(mappings.base)
end

M.fzf_config = function()
  telescope.load_extension('fzf')
end

return M
