local function termcodes(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local M = {}

M.general = {
	{
		-- Movement
		['H'] = { '0', 'Move to begining of line' },
		['L'] = { '$', 'Move to end of line' },

		-- switch k-j and {-}
		['K'] = { '{', 'Move behind next block' },
		['J'] = { '}', 'Move in front of previous block' },
		['}'] = { 'K', 'Bring up help' },
		['{'] = { 'J', 'Join lines' },
	},

	i = {
		['<CR>'] = { 'v:lua.isCursorInsideNewBlock() ? "<CR><esc>O" : "<CR>"', '', opts = { expr = true } },
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

		['<Leader>w'] = { ':w!<CR>', 'Save file' },

		['<Leader>e'] = { '<ESC>:e<CR>', 'Refresh file' },

		-- Tabs
		['<Leader>tj'] = { 'gT', 'Previous Tab' },
		['<Leader>tk'] = { 'gt', 'Next Tab' },
		['<Leader>tc'] = { '<ESC>:tabclose<CR>', 'Close Tab' },

		-- Buffers
		['<Leader>q'] = {
			'v:lua.closeBuffer() ? "<ESC>:bd<CR>" : "<ESC>:bd<CR>:q<CR>"',
			'',
			opts = { silent = true, expr = true },
		},
		['<Leader>bj'] = { '<ESC>:bnext<CR>', '', opts = { silent = true } },
		['<Leader>bk'] = { '<ESC>:bprevious<CR>', '', opts = { silent = true } },

		-- Splits
		['<Leader>ov'] = { '<CR>:vsp %:h<Tab><CR>', 'Open current fold in vertical window', opts = { silent = true } },
		['<Leader>oh'] = { '<CR>:sp %:h<Tab><CR>', 'Open current fold in horizontal window', opts = { silent = true } },

		['<C-h>'] = { '<C-w>h', 'window left' },
		['<C-l>'] = { '<C-w>l', 'window right' },
		['<C-j>'] = { '<C-w>j', 'window down' },
		['<C-k>'] = { '<C-w>k', 'window up' },

		['<C-s>+'] = { ':resize +3<CR>', '', opts = { silent = true } },
		['<C-s>-'] = { ':resize -3<CR>', '', opts = { silent = true } },

		-- Yank
		['y'] = { 'y$', 'Yank rest of line' },
		['yy'] = { 'Vy', 'Yank line' },

		['<Leader>V'] = { '<cmd>lua ReloadConfig()<CR>', 'Reload nvim config' },

		['<Leader>c'] = { ':nohlsearch<C-R><CR><CR><C-c>', 'Clear search highlight' },

		['<Leader>z'] = { 'za', 'Toggle fold' },

		['<Leader>sc'] = { ':setlocal spell!<CR>', 'Spellcheck' },

		['<Leader><Leader>h'] = { ':vert h ', 'Open vertical help' },

		["<Leader>'"] = { "e<ESC>a'<ESC>bi'<ESC>lel", "enclose with '' " },
		['<Leader>"'] = { 'e<ESC>a"<ESC>bi"<ESC>lel', 'enclose with "" ' },
	},

	t = { ['<C-x>'] = { termcodes('<C-\\><C-N>'), 'escape terminal mode' } },

	v = {
		['>'] = { '>gv', 'Improve indent in visual' },
		['<'] = { '<gv', 'Improve indent in visual' },

		["'"] = { "c''<ESC>P", "enclose with '' " },
		['"'] = { 'c""<ESC>P', 'enclose with "" ' },
		['`'] = { 'c``<ESC>P', 'enclose with `` ' },

		['('] = { 'c()<ESC>P', 'enclose with ()' },
		['{'] = { 'c{}<ESC>P', 'enclose with {}' },
		['['] = { 'c[]<ESC>P', 'enclose with []' },

		['<Up>'] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', opts = { expr = true } },
		['<Down>'] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', opts = { expr = true } },
	},

	x = {
		['j'] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', opts = { expr = true } },
		['k'] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', opts = { expr = true } },
		-- Don't copy the replaced text after pasting in visual mode
		-- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
		['p'] = { 'p:let @+=@0<CR>:let @"=@0<CR>', opts = { silent = true } },
	},
}

M.telescope = {
	n = {
		-- find
		['<leader>pp'] = { '<cmd> Telescope find_files <CR>', 'find files' },
		-- ['<leader>pp'] = { '<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>', 'find all' },
		['<leader>pw'] = { '<cmd> Telescope live_grep <CR>', 'live grep' },
		['<leader>pb'] = { '<cmd> Telescope buffers <CR>', 'find buffers' },
		['<leader>ph'] = { '<cmd> Telescope help_tags <CR>', 'help page' },
		['<leader>po'] = { '<cmd> Telescope oldfiles <CR>', 'find oldfiles' },
		['<leader>pk'] = { '<cmd> Telescope keymaps <CR>', 'show keys' },

		-- git
		['<leader>pm'] = { '<cmd> Telescope git_commits <CR>', 'git commits' },
		['<leader>pt'] = { '<cmd> Telescope git_status <CR>', 'git status' },

		-- pick a hidden term
		-- ['<leader>pt'] = { '<cmd> Telescope terms <CR>', 'pick hidden term' },
	},
}

M.blamer = {
	n = {
		['<Leader>gb'] = { '<ESC>:BlamerToggle<CR><C-c>', 'Toggle git blamer' },
	},
}

M.session_manager = {
	n = {
		['<Leader>ss'] = { '<CR>:SessionManager save_current_session<CR>', 'Save session', opts = { silent = true } },
		['<Leader>sl'] = { '<CR>:SessionManager load_last_session<CR>', 'Load last session', opts = { silent = true } },
  }
}

return M
