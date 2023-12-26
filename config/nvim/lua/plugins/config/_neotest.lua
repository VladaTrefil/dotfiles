local neotest_ok, neotest = pcall(require, 'neotest')

if not neotest_ok then
	return
end

local icons = require('core.icons')
local utils = require('core.utils')

local neotest_ns = vim.api.nvim_create_namespace('neotest')

local mappings = {
	n = {
		['<Leader>tn'] = {
			function()
				neotest.run.run()
			end,
			'Run nearest test',
		},
		['<Leader>tf'] = {
			function()
				neotest.run.run(vim.fn.expand('%'))
				neotest.summary.open()
			end,
			'Run file tests',
		},
		['<Leader>ta'] = {
			function()
				neotest.run.run(vim.fn.getcwd())
				neotest.summary.open()
			end,
			'Run all tests in directory',
		},
		['<Leader>tu'] = {
			function()
				neotest.summary.toggle()
			end,
			'Toggle testing UI',
		},
		['<Leader>to'] = {
			function()
				neotest.output.open()
			end,
			'Run last test',
		},
	},
}

utils.load_mappings(mappings)

vim.diagnostic.config({
	virtual_text = {
		format = function(diagnostic)
			return diagnostic.message
				:gsub('\n', ' ')
				:gsub('\t', ' ')
				:gsub('%s+', ' ')
				:gsub('^%s+', '')
		end,
	},
}, neotest_ns)

neotest.setup({
	adapters = {
		require('neotest-minitest')({
			test_cmd = function()
				return vim.tbl_flatten({
					'bundle',
					'exec',
					'rails',
					'test',
				})
			end,
		}),
	},
	icons = {
		failed = icons.Error,
		passed = icons.Success,
		running = icons.Sync,
		unknown = icons.Question,
		skipped = icons.Forward,
		running_animated = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
	},
	diagnostic = {
		severity = vim.diagnostic.severity.WARN,
		enabled = true,
	},
	status = {
		enabled = true,
		signs = false,
		virtual_text = true,
	},
	summary = {
		enabled = true,
		animated = true,
		follow = true,
		expand_errors = true,
		mappings = {
			attach = 'a',
			clear_marked = 'M',
			clear_target = 'T',
			debug = 'd',
			debug_marked = 'D',
			expand = { '<CR>', '<2-LeftMouse>' },
			expand_all = 'e',
			jumpto = 'i',
			mark = 'm',
			next_failed = 'J',
			output = 'o',
			prev_failed = 'K',
			run = 'r',
			run_marked = 'R',
			short = 'O',
			stop = 'u',
			target = 't',
			watch = 'w',
		},
		open = 'botright vsplit | vertical resize 50',
	},
	consumers = {
		overseer = require('neotest.consumers.overseer'),
	},
	overseer = {
		enabled = true,
		force_default = true,
	},
})
