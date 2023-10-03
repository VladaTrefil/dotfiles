local telescope_ok, telescope = pcall(require, 'telescope')

if not telescope_ok then
  vim.notify("Telescope lua package doesn't exist")
  return
end

VIMGREP_ARGUMENTS = {
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

FILE_IGNORE_PATTERNS = {
  'node_modules',
  '%.ttf',
  '%.eof',
  '%.woff',
  '%.woff2',
  '.git/',
}

local mappings = require('plugins.config._telescope.mappings')

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
  notify = {
    layout_strategy = 'vertical',
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

require('core.utils').load_mappings(mappings.base)
require('plugins.config._telescope.utils').create_autocmds()

telescope.setup({
  defaults = {
    vimgrep_arguments = VIMGREP_ARGUMENTS,
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
  },
  pickers = pickers,
  extensions = extensions,
})
