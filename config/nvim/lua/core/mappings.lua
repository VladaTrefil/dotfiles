local function termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local M = {}

M.general = {
  {
    -- Movement
    ['H'] = { '0', 'Move to begining of line' },
    ['L'] = { '$', 'Move to end of line' },

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

  n = {
    ['<ESC>'] = { '<cmd> noh <CR>', 'no highlight' },
    ['<Space>'] = { '<NOP>', 'no highlight' },
    ['<BS>'] = { '<C-o>', 'Backspace goes back' },

    ['<Leader>w'] = { '<cmd> w! <CR>', 'Save file' },

    ['<Leader>e'] = { '<cmd> e <CR>', 'Refresh file' },

    -- Tabs
    ['<Leader>tj'] = { 'gT', 'Previous Tab' },
    ['<Leader>tk'] = { 'gt', 'Next Tab' },
    ['<Leader>tc'] = { '<cmd> tabclose <CR>', 'Close Tab' },

    -- Buffers
    ['<Leader>q'] = { '<cmd> q <CR>', 'Close buffer or window', opts = { silent = true } },
    ['<Leader>Q'] = { '<cmd> qa! <CR>', 'Close NVIM', opts = { silent = true } },
    ['<Leader>bj'] = { '<cmd> bprevious <CR>', 'Previous buffer', opts = { silent = true } },
    ['<Leader>bk'] = { '<cmd> bnext <CR>', 'Next buffer', opts = { silent = true } },

    -- Splits
    ['<Leader>ov'] = { '<cmd> vsp %:h<Tab> <CR>', 'Open current fold in vertical window', opts = { silent = true } },
    ['<Leader>oh'] = { '<cmd> sp %:h<Tab> <CR>', 'Open current fold in horizontal window', opts = { silent = true } },

    ['<C-h>'] = { '<C-w>h', 'window left' },
    ['<C-l>'] = { '<C-w>l', 'window right' },
    ['<C-j>'] = { '<C-w>j', 'window down' },
    ['<C-k>'] = { '<C-w>k', 'window up' },

    ['<C-s>+'] = { '<cmd> resize +3 <CR>', '', opts = { silent = true } },
    ['<C-s>-'] = { '<cmd> resize -3 <CR>', '', opts = { silent = true } },

    -- Yank
    ['y'] = { 'y$', 'Yank rest of line' },
    ['yy'] = { 'Vy', 'Yank line' },

    ['<Leader>V'] = { '<cmd> lua ReloadConfig() <CR>', 'Reload nvim config' },

    ['<Leader>c'] = { '<cmd> noh <CR>', 'Clear search highlight' },

    ['<Leader>z'] = { 'za', 'Toggle fold' },

    ['<Leader>sc'] = { '<cmd> setlocal spell! <CR>', 'Spellcheck' },

    ['<Leader><Leader>h'] = { ':vert h ', 'Open vertical help' },

    ["<Leader>'"] = { "e<ESC>a'<ESC>bi'<ESC>lel", "enclose with '' " },
    ['<Leader>"'] = { 'e<ESC>a"<ESC>bi"<ESC>lel', 'enclose with "" ' },

    ['<Leader>ss'] = {
      function()
        require('core.utils').save_session()
      end,
      'Save session',
      -- opts = { silent = true, expr = true },
    },
  },

  t = {
    ['<C-x>'] = { termcodes('<C-\\><C-N>'), 'escape terminal mode' }
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

    -- ['<Up>'] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', opts = { expr = true } },
    -- ['<Down>'] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', opts = { expr = true } },
  },

  x = {
    -- ['j'] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', opts = { expr = true } },
    -- ['k'] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', opts = { expr = true } },
    -- Don't copy the replaced text after pasting in visual mode
    -- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
    ['p'] = { 'p:let @+=@0<CR>:let @"=@0<CR>', opts = { silent = true } },
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

M.telescope = function(actions)
  -- Switch to window with buffer if exists or do default select action
  local function select_buffer(prompt_bufnr)
    local action_state = require("telescope.actions.state")

    local entry = action_state.get_selected_entry()
    local winid = vim.fn.win_findbuf(entry.bufnr)[1]

    if winid then
      vim.fn.win_gotoid(winid)
    else
      actions.select_default(prompt_bufnr)
    end
  end

  return {
    base = {
      n = {
        -- find
        -- ['<leader>pp'] = { '<cmd> Telescope find_files <CR>', 'find files' },
        ['<leader>pp'] = { '<cmd> Telescope find_files follow=true hidden=true <CR>', 'find all' },
        ['<leader>pw'] = { '<cmd> Telescope live_grep <CR>', 'live grep' },
        ['<leader>pb'] = { '<cmd> Telescope buffers <CR>', 'find buffers' },
        ['<leader>ph'] = { '<cmd> Telescope help_tags <CR>', 'help page' },
        ['<leader>po'] = { '<cmd> Telescope oldfiles <CR>', 'find oldfiles' },
        ['<leader>pk'] = { '<cmd> Telescope keymaps <CR>', 'show keys' },

        -- -- git
        ['<leader>pm'] = { '<cmd> Telescope git_commits <CR>', 'git commits' },
        ['<leader>pt'] = { '<cmd> Telescope git_status <CR>', 'git status' },
      },
    },
    window = {
      n = {
        ['q']       = actions.close,
        ["<C-k>"]   = actions.move_selection_previous,
        ["<C-j>"]   = actions.move_selection_next,
        ["<C-s>"]   = actions.file_split,
      },
      i = {
        ["<C-k>"]   = actions.move_selection_previous,
        ["<C-j>"]   = actions.move_selection_next,
        ["<C-s>"]   = actions.file_split,
        ["<C-p>"]   = false,
        ["<C-n>"]   = false,
      },
    },
    pickers = {
      buffers = {
        n = {
          ['<enter>'] = select_buffer,
          ['d'] = actions.delete_buffer,
        },
        i = {
          ['<enter>'] = select_buffer,
        }
      },
      help_tags = {
        n = {
          ['<C-v>'] = actions.file_vsplit,
          ['<C-s>'] = actions.file_split,
        },
        i = {
          ['<C-v>'] = actions.file_vsplit,
          ['<C-s>'] = actions.file_split,
        }
      }
    },
  }
end

M.cmp_api = function(cmp)
  return {
    ['<C-b>']     = cmp.mapping.scroll_docs(-4),
    ['<C-f>']     = cmp.mapping.scroll_docs(4),
    ['<C-k>']     = cmp.mapping.select_prev_item(),
    ['<C-j>']     = cmp.mapping.select_next_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>']     = cmp.mapping.abort(),
    ['<Tab>']     = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }
end

return M
