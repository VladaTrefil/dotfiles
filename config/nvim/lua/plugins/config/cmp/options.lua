local M = {}

local cmp = require('cmp')

local cmp_utils = require('plugins.config.cmp.utils')
local format = require('plugins.config.cmp.format')
local mappings = require('plugins.config.cmp.mappings')

local WIDE_HEIGHT = 40

local window = {
	documentation = {
		winhighlight = 'Normal:CmpPmenuDocumentation,FloatBorder:CmpPmenuDocumentationBorder,CursorLine:PmenuSel,Search:None',
		maxwidth = math.floor((WIDE_HEIGHT * 2) * (vim.o.columns / (WIDE_HEIGHT * 2 * 16 / 9))),
		maxheight = math.floor(WIDE_HEIGHT * (vim.o.lines / WIDE_HEIGHT)),
		side_padding = 2,
	},
	completion = {
		winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:CmpPmenuSel,Search:None',
		side_padding = 0,
		col_offset = -4,
	},
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

local common_opts = {
	preselect = cmp.PreselectMode.Item,
	mapping = cmp.mapping.preset.insert(mappings),
	window = window,
	performance = {
		max_view_entries = 60,
	},
	confirmation = {
		default_behavior = cmp.ConfirmBehavior.Insert,
	},
	formatting = {
		fields = { 'menu', 'abbr', 'kind' },
		format = format.format_selection_item,
	},
	completion = {
		completeopt = 'menu,menuone,preview,noselect',
	},
}

local sources = {
	editor = {
		{ name = 'ultisnips', priority = 1000 },
		{ name = 'nvim_lsp', priority = 750 },
		{ name = 'copilot', priority = 600 },
		{ name = 'buffer', priority = 400, option = { get_bufnrs = cmp_utils.get_buffers } },
		{ name = 'path', priority = 250 },
	},
}

M.editor_opts = vim.tbl_deep_extend('force', common_opts, {
	sources = sources.editor,
	sorting = sort,
	snippet = {
		expand = cmp_utils.expand_snippet,
	},
	experimental = {
		ghost_text = true,
	},
})

return M
