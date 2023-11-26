local M = {}

local cmp = require('cmp')

local cmp_utils = require('plugins.config.cmp.utils')
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
	autocomplete = cmp.TriggerEvent.InsertEnter,
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
		format = cmp_utils.format_completion_item,
	},
	completion = {
		completeopt = 'menu,menuone,preview,noselect',
	},
}

local sources = {
	editor = {
		{ name = 'ultisnips', priority = 1000 },
		{ name = 'nvim_lsp', priority = 800 },
		{ name = 'treesitter', priority = 700 },
		{ name = 'copilot', priority = 600 },
		{ name = 'buffer', priority = 100, option = { get_bufnrs = cmp_utils.get_buffers } },
		{ name = 'path', priority = 250 },
	},
	cmdline = {
		{ name = 'path', priority = 0, option = { trailing_slash = true } },
		{
			name = 'cmdline',
			priority = 500,
			keyword_pattern = [=[[^[:blank:]%]*]=],
			option = {
				ignore_cmds = { 'Man', 'vsp', '%' },
			},
		},
		-- { name = 'nvim_lsp', priority = 1000 },
		{ name = 'copilot', priority = 1000 },
		{ name = 'buffer', priority = 1000 },
	},
	search = {
		{ name = 'buffer' },
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

M.cmd_opts = vim.tbl_deep_extend('force', common_opts, {
	sources = sources.cmdline,
})

M.search_opts = vim.tbl_deep_extend('force', common_opts, {
	sources = sources.search,
})

return M
