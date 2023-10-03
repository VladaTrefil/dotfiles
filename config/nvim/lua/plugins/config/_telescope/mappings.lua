local M = {}

M.base = {
  n = {
    ['<leader>pm'] = { '<cmd> Telescope <CR>', 'Menu [telescope]' },
    ['<leader>pp'] = {
      '<cmd> Telescope find_files follow=true hidden=true <CR>',
      'Search in project',
    },
    ['<leader>pw'] = {
      '<cmd> Telescope live_grep <CR>',
      'Search in project by pattern [telescope]',
    },
    ['<leader>pb'] = { '<cmd> Telescope buffers <CR>', 'Buffers [telescope]' },
    ['<leader>ph'] = { '<cmd> Telescope help_tags <CR>', 'Help page [telescope]' },
    ['<leader>po'] = { '<cmd> Telescope oldfiles <CR>', 'Recent files [telescope]' },

    -- -- vim internals
    ['<leader>pvk'] = { '<cmd> Telescope keymaps <CR>', 'Keymaps [telescope]' },
    ['<leader>pvm'] = { '<cmd> Telescope man_pages <CR>', 'Man pages [telescope]' },
    ['<leader>pvn'] = { '<cmd> Telescope notify <CR>', 'Notifications [telescope]' },
    ['<leader>pvc'] = {
      '<cmd> Telescope command_history <CR>',
      'Command history [telescope]',
    },
    ['<leader>pvr'] = {
      '<cmd> Telescope reloader <CR>',
      'Lua module reloader [telescope]',
    },
    ['<leader>pvh'] = { '<cmd> Telescope highlights <CR>', 'Highlights [telescope]' },
    ['<leader>pva'] = {
      '<cmd> Telescope autocommands <CR>',
      'Autocommands [telescope]',
    },
    ['<leader>pvo'] = { '<cmd> Telescope vim_options <CR>', 'Vim options [telescope]' },

    -- -- git
    ['<leader>gc'] = { '<cmd> Telescope git_commits <CR>', 'git commits [telescope]' },
    ['<leader>gs'] = { '<cmd> Telescope git_status <CR>', 'git status [telescope]' },
  },
}

local actions = require('telescope.actions')

M.window = {
  n = {
    ['q'] = actions.close,
    ['<C-k>'] = actions.move_selection_previous,
    ['<C-j>'] = actions.move_selection_next,
    ['<C-s>'] = actions.file_split,
  },
  i = {
    ['<C-k>'] = actions.move_selection_previous,
    ['<C-j>'] = actions.move_selection_next,
    ['<C-s>'] = actions.file_split,
    ['<C-p>'] = false,
    ['<C-n>'] = false,
  },
}

local telescope_utils = require('plugins.config._telescope.utils')

M.pickers = {
  find_files = {
    -- n = {
    --   ['<C-t>'] = select_file_entry,
    -- },
    -- i = {
    --   ['<C-t>'] = select_file_entry,
    -- }
  },
  buffers = {
    n = {
      ['<enter>'] = telescope_utils.select_buffer,
      ['d'] = actions.delete_buffer,
    },
    i = {
      ['<enter>'] = telescope_utils.select_buffer,
    },
  },
  help_tags = {
    -- n = {
    --   ['<C-v>'] = actions.select_vertical,
    --   ['<C-s>'] = actions.select_horizontal,
    -- },
    --   i = {
    --     ['<C-v>'] = actions.file_vsplit,
    --     ['<C-s>'] = actions.file_split,
    --   }
  },
}

return M
