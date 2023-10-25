local M = {}

local utils = require('core.utils')

function on_paste()
  if vim.bo.filetype == 'yaml' then
    vim.api.nvim_feedkeys('p', 'n', false)
  else
    utils.paste_as_insert()
  end
end

function on_paste_reverse()
  if vim.bo.filetype == 'yaml' then
    vim.api.nvim_feedkeys('P', 'n', false)
  else
    utils.paste_as_insert(true)
  end
end

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

    ['J'] = { 'mzJ`z', 'Keep cursor when joining lines' },

    ['p'] = { on_paste, 'Paste as insert' },
    ['P'] = { on_paste_reverse, 'Paste as insert reverse' },

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

    ['<C-h>'] = { '<C-w>h', 'Window left' },
    ['<C-l>'] = { '<C-w>l', 'Window right' },
    ['<C-j>'] = { '<C-w>j', 'Window down' },
    ['<C-k>'] = { '<C-w>k', 'Window up' },

    -- Yank
    ['Y'] = { 'y$', 'Yank rest of line' },
    ['yy'] = { 'Vy', 'Yank line' },

    ['<Leader>z'] = { 'za', 'Toggle fold' },

    ["<Leader>'"] = { "e<ESC>a'<ESC>bi'<ESC>lel", "Enclose with '' " },
    ['<Leader>"'] = { 'e<ESC>a"<ESC>bi"<ESC>lel', 'Enclose with "" ' },

    ['<Leader>sh'] = { '<cmd> setlocal spell! <CR>', 'Spellcheck' },

    ['<leader>ss'] = {
      [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
      'Open substitution with current word',
    },

    ['<leader>su'] = {
      utils.switch_case_line_under_cursor,
      'Switch case of word under cursor',
    },

    ['<C-Down>'] = { ':resize -10<CR>', 'Resize up' },
    ['<C-Up>'] = { ':resize +10<CR>', 'Resize down' },
    ['<C-Right>'] = { ':vertical resize -10<CR>', 'Resize left' },
    ['<C-Left>'] = { ':vertical resize +10<CR>', 'Resize right' },
  },

  i = {
    ['<CR>'] = {
      'v:lua.isCursorInsideNewBlock() ? "<CR><esc>O" : "<CR>"',
      'New line with correction for blocks',
      opts = { silent = true, expr = true },
    },

    -- go to  beginning and end
    ['<C-b>'] = { '<ESC>^i', 'Beginning of line' },
    ['<C-e>'] = { '<End>', 'End of line' },

    -- navigate within insert mode
    ['<C-h>'] = { '<Left>', 'Move left' },
    ['<C-l>'] = { '<Right>', 'Move right' },
    ['<C-j>'] = { '<Down>', 'Move down' },
    ['<C-k>'] = { '<Up>', 'Move up' },
  },

  t = {
    ['<C-x>'] = { utils.termcodes('<C-\\><C-N>'), 'Escape terminal mode' },
  },

  v = {
    ['>'] = { '>gv', 'Improve indent in visual' },
    ['<'] = { '<gv', 'Improve indent in visual' },

    ["'"] = { "c''<ESC>P", "Enclose with '' " },
    -- ['"'] = { 'c""<ESC>P', 'Enclose with "" ' },
    ['`'] = { 'c``<ESC>P', 'Enclose with `` ' },

    ['('] = { 'c()<ESC>P', 'Enclose with ()' },
    ['{'] = { 'c{}<ESC>P', 'Enclose with {}' },
    ['['] = { 'c[]<ESC>P', 'Enclose with []' },

    ['J'] = { "<cmd>m '>+1<CR>gv=gv", 'Move selected block down a line' },
    ['K'] = { "<cmd>m '>-2<CR>gv=gv", 'Move selected block up a line' },

    ['<Leader>sc'] = { utils.convert_color_code, 'Convert selection to hex/rgb' },
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
