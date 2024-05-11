local gitsigns = require('gitsigns')

return {
	n = {
		['<Leader>gs'] = { gitsigns.stage_hunk, 'Stage hunk' },
		['<Leader>gS'] = {
			function()
				gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
			end,
			'Stage line',
		},
		['<Leader>gu'] = { gitsigns.undo_stage_hunk, 'Undo Stage hunk' },
		['<Leader>gp'] = { gitsigns.preview_hunk, 'Preview hunk' },
		['<Leader>gb'] = {
			function()
				gitsigns.blame_line({ full = true })
			end,
			'Blame line',
		},
	},
}
