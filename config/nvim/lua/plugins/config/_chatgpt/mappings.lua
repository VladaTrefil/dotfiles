local M = {}

M.base = {
	n = {
		['<leader>cc'] = { '<cmd>ChatGPT<CR>', 'ChatGPT' },
		['<leader>ce'] = {
			'<cmd>ChatGPTEditWithInstruction<CR>',
			'Edit with instruction',
		},
		['<leader>cg'] = {
			'<cmd>ChatGPTRun grammar_correction<CR>',
			'Grammar Correction',
		},
		['<leader>ct'] = { '<cmd>ChatGPTRun translate<CR>', 'Translate' },
		['<leader>ck'] = { '<cmd>ChatGPTRun keywords<CR>', 'Keywords' },
		['<leader>cd'] = { '<cmd>ChatGPTRun docstring<CR>', 'Docstring' },
		['<leader>ca'] = { '<cmd>ChatGPTRun add_tests<CR>', 'Add Tests' },
		['<leader>co'] = {
			'<cmd>ChatGPTRun optimize_code<CR>',
			'Optimize Code',
		},
		['<leader>cs'] = { '<cmd>ChatGPTRun summarize<CR>', 'Summarize' },
		['<leader>cf'] = { '<cmd>ChatGPTRun fix_bugs<CR>', 'Fix Bugs' },
		['<leader>cx'] = { '<cmd>ChatGPTRun explain_code<CR>', 'Explain Code' },
		['<leader>cr'] = { '<cmd>ChatGPTRun roxygen_edit<CR>', 'Roxygen Edit' },
		['<leader>cl'] = {
			'<cmd>ChatGPTRun code_readability_analysis<CR>',
			'Code Readability Analysis',
		},
	},
	v = {
		['<leader>ce'] = {
			'<cmd>ChatGPTEditWithInstruction<CR>',
			'Edit with instruction',
		},
		['<leader>cg'] = {
			'<cmd>ChatGPTRun grammar_correction<CR>',
			'Grammar Correction',
		},
		['<leader>ct'] = { '<cmd>ChatGPTRun translate<CR>', 'Translate' },
		['<leader>ck'] = { '<cmd>ChatGPTRun keywords<CR>', 'Keywords' },
		['<leader>cd'] = { '<cmd>ChatGPTRun docstring<CR>', 'Docstring' },
		['<leader>ca'] = { '<cmd>ChatGPTRun add_tests<CR>', 'Add Tests' },
		['<leader>co'] = {
			'<cmd>ChatGPTRun optimize_code<CR>',
			'Optimize Code',
		},
		['<leader>cs'] = { '<cmd>ChatGPTRun summarize<CR>', 'Summarize' },
		['<leader>cf'] = { '<cmd>ChatGPTRun fix_bugs<CR>', 'Fix Bugs' },
		['<leader>cx'] = { '<cmd>ChatGPTRun explain_code<CR>', 'Explain Code' },
		['<leader>cr'] = { '<cmd>ChatGPTRun roxygen_edit<CR>', 'Roxygen Edit' },
		['<leader>cl'] = {
			'<cmd>ChatGPTRun code_readability_analysis<CR>',
			'Code Readability Analysis',
		},
	},
}

M.window = {
	close = '<C-q>',
	yank_last = '<C-y>',
	yank_last_code = '<C-k>',
	scroll_up = '<C-u>',
	scroll_down = '<C-d>',
	new_session = '<C-n>',
	cycle_windows = '<Tab>',
	cycle_modes = '<C-f>',
	next_message = '<C-j>',
	prev_message = '<C-k>',
	select_session = '<Space>',
	rename_session = 'r',
	delete_session = 'd',
	draft_message = '<C-d>',
	edit_message = 'e',
	delete_message = 'd',
	toggle_settings = '<C-o>',
	toggle_message_role = '<C-r>',
	toggle_system_role_open = '<C-s>',
	stop_generating = '<C-x>',
}

return M
