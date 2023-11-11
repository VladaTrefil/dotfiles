local present, cmp = pcall(require, 'cmp')

if not present then
	return
end

local WIDE_HEIGHT = 40

local cmp_utils = require('plugins.config.cmp.utils')
local format = require('plugins.config.cmp.format')
local mappings_config = require('core.mappings').cmp_api(cmp)

local window = {
	documentation = {
		winhighlight = 'Normal:CmpPmenuDocumentation,FloatBorder:CmpPmenuDocumentationBorder,CursorLine:PmenuSel,Search:None',
		maxwidth = math.floor((WIDE_HEIGHT * 2) * (vim.o.columns / (WIDE_HEIGHT * 2 * 16 / 9))),
		maxheight = math.floor(WIDE_HEIGHT * (WIDE_HEIGHT / vim.o.lines)),
		side_padding = 2,
	},
	completion = {
		winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:CmpPmenuSel,Search:None',
		side_padding = 0,
		col_offset = -4,
	},
}

local sources = {
	{ name = 'ultisnips', priority = 1000 },
	{ name = 'nvim_lsp', priority = 750 },
	{ name = 'copilot', priority = 600 },
	{ name = 'buffer', priority = 400, option = { get_bufnrs = cmp_utils.get_buffers } },
	{ name = 'path', priority = 250 },
}

local sort = {
	priority_weight = 2,
	comparators = {
		cmp.config.compare.exact,
		cmp.config.compare.scopes,
		cmp.config.compare.score,
		cmp.config.compare.offset,
		cmp.config.compare.order,
		cmp.config.compare.sort_text,
	},
}

local completeopt = 'menu,menuone,preview'

cmp.setup({
	window = window,
	sources = sources,
	sorting = sort,
	snippet = {
		expand = cmp_utils.expand_snippet,
	},
	formatting = {
		fields = { 'menu', 'abbr', 'kind' },
		format = format.format_selection_item,
	},
	mapping = cmp.mapping.preset.insert(mappings_config),
	completion = {
		completeopt = completeopt,
	},
	experimental = {
		ghost_text = true,
	},
	performance = {
		max_view_entries = 60,
	},
})

-- CursorHold event hold time in milliseconds, also used for swapfile auto-save
vim.o.updatetime = 250
-- Options for the behavior of completion menu
vim.go.completeopt = completeopt
-- Maximum number to show in the completion menu
vim.o.pumheight = 20

vim.api.nvim_create_autocmd('BufWritePost', {
	pattern = '*.snippets',
	callback = function()
		vim.cmd('CmpUltisnipsReloadSnippets')
	end,
})

vim.api.nvim_create_augroup('lsp_diagnostics_hold', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorHold' }, {
	pattern = '*',
	group = 'lsp_diagnostics_hold',
	callback = function()
		local opts = {
			focusable = false,
			close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
			border = 'rounded',
			source = 'always',
			prefix = ' ',
			scope = 'cursor',
		}

		vim.diagnostic.open_float(nil, opts)
	end,
})
