local M = {}

local utils = require('core.utils')

M.general = {
  {
    ['H'] = { '0', 'Move to beginning of line' },
    ['L'] = { '$', 'Move to end of line' },
  },

  n = {
    ['<C-d>'] = { '<C-d>zz', 'Centered cursor while scrolling' },
    ['<C-u>'] = { '<C-u>zz', 'Centered cursor while scrolling' },

    ['n'] = { 'nzzzv', 'Centered cursor while jumping to next search' },
    ['N'] = { 'Nzzzv', 'Centered cursor while jumping to previous search' },

    ['J'] = { 'mzJ`z', 'keep cursor when joining lines' },

    ['p'] = { utils.paste_as_insert, 'Paste with indent' },
    ['P'] = { utils.paste_as_insert_reverse, 'Paste Before with indent' },

    ['<ESC>'] = { utils.clear_ui, 'Clear UI', opts = { silent = true } },
    ['<BS>'] = { '<C-o>', 'Backspace goes back' },

    ['<Leader>E'] = {
      '<cmd> :execute "!dolphin " . shellescape(getcwd(),1) <CR>',
      'Open current directory in explorer',
      opts = { silent = true },
    },

    ['<Leader>w'] = { '<cmd> w! <CR>', 'Save file' },
    ['<Leader>e'] = { '<cmd> e <CR>', 'Refresh file' },

    -- Tabs
    ['<Leader>tj'] = { 'gT', 'Previous Tab' },
    ['<Leader>tk'] = { 'gt', 'Next Tab' },
    ['<Leader>tc'] = { '<cmd> tabclose <CR>', 'Close Tab' },

    -- Buffers
    ['<Leader>q'] = { '<cmd> q <CR>', 'Close window', opts = { silent = true } },
    ['<Leader>Q'] = { '<cmd> qa! <CR>', 'Close NVIM', opts = { silent = true } },
    ['<Leader>bj'] = { '<cmd> bprevious <CR>', 'Previous buffer', opts = { silent = true } },
    ['<Leader>bk'] = { '<cmd> bnext <CR>', 'Next buffer', opts = { silent = true } },

    ['<C-h>'] = { '<C-w>h', 'window left' },
    ['<C-l>'] = { '<C-w>l', 'window right' },
    ['<C-j>'] = { '<C-w>j', 'window down' },
    ['<C-k>'] = { '<C-w>k', 'window up' },

    -- Yank
    ['Y'] = { 'y$', 'Yank rest of line' },
    ['yy'] = { 'Vy', 'Yank line' },

    ['<Leader>z'] = { 'za', 'Toggle fold' },

    ['<Leader>sc'] = { '<cmd> setlocal spell! <CR>', 'Spellcheck' },

    ["<Leader>'"] = { "e<ESC>a'<ESC>bi'<ESC>lel", "enclose with '' " },
    ['<Leader>"'] = { 'e<ESC>a"<ESC>bi"<ESC>lel', 'enclose with "" ' },

    ['<leader>s'] = {
      [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
      'open substitution with current word',
    },

    ['<C-Down>'] = { ':resize -10<CR>', 'Resize up' },
    ['<C-Up>'] = { ':resize +10<CR>', 'Resize down' },
    ['<C-Right>'] = { ':vertical resize -10<CR>', 'Resize left' },
    ['<C-Left>'] = { ':vertical resize +10<CR>', 'Resize right' },
  },

  i = {
    ['<CR>'] = {
      'v:lua.isCursorInsideNewBlock() ? "<CR><esc>O" : "<CR>"',
      '',
      opts = { silent = true, expr = true },
    },

    -- go to  beginning and end
    ['<C-b>'] = { '<ESC>^i', 'beginning of line' },
    ['<C-e>'] = { '<End>', 'end of line' },

    -- navigate within insert mode
    ['<C-h>'] = { '<Left>', 'move left' },
    ['<C-l>'] = { '<Right>', 'move right' },
    ['<C-j>'] = { '<Down>', 'move down' },
    ['<C-k>'] = { '<Up>', 'move up' },
  },

  t = {
    ['<C-x>'] = { utils.termcodes('<C-\\><C-N>'), 'escape terminal mode' },
  },

  v = {
    ['>'] = { '>gv', 'Improve indent in visual' },
    ['<'] = { '<gv', 'Improve indent in visual' },

    ["'"] = { "c''<ESC>P", "enclose with '' " },
    ['"'] = { 'c""<ESC>P', 'enclose with "" ' },
    ['`'] = { 'c``<ESC>P', 'enclose with `` ' },

    ['('] = { 'c()<ESC>P', 'enclose with ()' },
    ['{'] = { 'c{}<ESC>P', 'enclose with {}' },
    ['['] = { 'c[]<ESC>P', 'enclose with []' },

    ['J'] = { "<cmd>m '>+1<CR>gv=gv", 'move selected block down a line' },
    ['K'] = { "<cmd>m '>-2<CR>gv=gv", 'move selected block up a line' },
  },

  x = {
    -- Don't copy the replaced text after pasting in visual mode
    -- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
    -- ['p'] = { 'p:let @+=@0<CR>:let @"=@0<CR>', opts = { silent = true } },
  },
}

M.blamer = {
  n = {
    ['<Leader>gb'] = { '<cmd> BlamerToggle <CR>', 'Toggle git blamer' },
  },
}

M.lazygit = {
  n = {
    ['<Leader>gg'] = { '<cmd>LazyGit<cr>', 'Open Lazygit' },
  },
}

M.ultisnips = {
  n = {
    ['<Leader>us'] = { '<cmd> UltiSnipsEdit <cr>', 'Edit ultisnippets' },
  },
}

M.codespell = {
  n = {
    ['<Leader>Ci'] = {
      function()
        utils.add_codespell_ignore_misspell()
      end,
      'Add misspelling on current line to codespell ignore list',
    },
  },
}

M.telescope = function(actions)
  local action_state = require('telescope.actions.state')
  local action_utils = require('telescope.actions.utils')

  -- Switch to window with buffer if exists or do default select action
  local function select_buffer(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    local winid = vim.fn.win_findbuf(entry.bufnr)[1]

    if winid then
      vim.fn.win_gotoid(winid)
    else
      actions.select_default(prompt_bufnr)
    end
  end

  -- local function select_file_entry(prompt_bufnr)
  --   local picker = action_state.get_current_picker(prompt_bufnr)
  --   local selections = picker:get_multi_selection()mappmapp
  --
  --   if #selections > 1 then
  --     for i, entry in ipairs(selections) do
  --       print(i)
  --       if i == 1 then
  --         vim.cmd.tabnew(entry.value)
  --       else
  --         vim.cmd.vsplit(entry.value)
  --       end
  --     end
  --
  --     vim.cmd('stopinsert')
  --   else
  --     actions.select_default(prompt_bufnr)
  --   end
  -- end

  return {
    base = {
      n = {
        -- find
        -- ['<leader>pp'] = { '<cmd> Telescope find_files <CR>', 'find files' },
        ['<leader>pp'] = {
          '<cmd> Telescope find_files follow=true hidden=true <CR>',
          'find all',
        },
        ['<leader>pw'] = { '<cmd> Telescope live_grep <CR>', 'live grep' },
        ['<leader>pb'] = { '<cmd> Telescope buffers <CR>', 'find buffers' },
        ['<leader>ph'] = { '<cmd> Telescope help_tags <CR>', 'help page' },
        ['<leader>po'] = { '<cmd> Telescope oldfiles <CR>', 'find oldfiles' },

        -- -- vim internals
        ['<leader>pvk'] = { '<cmd> Telescope keymaps <CR>', 'show keys' },
        ['<leader>pvm'] = { '<cmd> Telescope man_pages <CR>', 'show keys' },
        ['<leader>pvc'] = { '<cmd> Telescope command_history <CR>', 'show keys' },
        ['<leader>pvr'] = { '<cmd> Telescope reloader <CR>', 'show keys' },
        ['<leader>pvh'] = { '<cmd> Telescope highlights <CR>', 'show keys' },
        ['<leader>pva'] = { '<cmd> Telescope autocommands <CR>', 'show keys' },
        ['<leader>pvo'] = { '<cmd> Telescope vim_options <CR>', 'show keys' },

        -- -- git
        ['<leader>gc'] = { '<cmd> Telescope git_commits <CR>', 'git commits' },
        ['<leader>gs'] = { '<cmd> Telescope git_status <CR>', 'git status' },
      },
    },
    window = {
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
    },
    pickers = {
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
          ['<enter>'] = select_buffer,
          ['d'] = actions.delete_buffer,
        },
        i = {
          ['<enter>'] = select_buffer,
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
    },
  }
end

M.cmp_api = function(cmp)
  local cmp_utils = require('plugins.config.cmp.utils')

  return {
    -- add function for switch between docs and completion
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping(cmp_utils.on_confirm, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(cmp_utils.on_confirm_inverse, { 'i', 's' }),
  }
end

M.sessions = function(mngr)
  return {}
end

return M
