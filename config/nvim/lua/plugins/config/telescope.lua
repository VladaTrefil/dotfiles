-- Telescope Settings:
---------------------------------------------------------------

local present, telescope = pcall(require, 'telescope')

if not present then
  return
end

local load_mappings = require('core.utils').load_mappings
local actions = require('telescope.actions')

FILE_IGNORE_PATTERNS = { 'node_modules', '*.ttf', '*.woff*', '*.eot*' }

local options = {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--vimgrep',
      '--trim', -- add this value
    },
    prompt_prefix = '   ',
    selection_caret = '  ',
    entry_prefix = '  ',
    initial_mode = 'insert',
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
    file_ignore_patterns = FILE_IGNORE_PATTERNS,
    generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
    path_display = { truncate = 3 },
    winblend = 0,
    color_devicons = true,
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
    file_previewer = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require('telescope.previewers').buffer_previewer_maker,
    mappings = require('core.mappings').telescope_api(actions),
  },
  extensions_list = { 'themes', 'terms' },
}

local M = {}

M.core_config = function()
  telescope.setup(options)

  -- load extensions
  pcall(function()
    for _, ext in ipairs(options.extensions_list) do
      telescope.load_extension(ext)
    end
  end)

  local mappings = require('core.mappings').telescope
  load_mappings(mappings)
end

M.fzf_config = function()
  telescope.load_extension('fzf')
end

return M
