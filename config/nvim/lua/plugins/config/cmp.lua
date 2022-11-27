local present, cmp = pcall(require, 'cmp')

if not present then
	return
end

local lspkind = require('lspkind')

local window = {
	documentation = {
		border = 'rounded',
		winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
	},
	completion = {
		border = 'rounded',
		winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
	},
}

local mapping = cmp.mapping.preset.insert({
	['<C-b>'] = cmp.mapping.scroll_docs(-4),
	['<C-f>'] = cmp.mapping.scroll_docs(4),
	['<C-k>'] = cmp.mapping.select_prev_item(),
	['<C-j>'] = cmp.mapping.select_next_item(),
	['<C-Space>'] = cmp.mapping.complete(),
	['<C-e>'] = cmp.mapping.abort(),
	-- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	['<Tab>'] = cmp.mapping.confirm({ select = true }),
})

local sorting = {
	comparators = {
		cmp.config.compare.exact,
		cmp.config.compare.locality,
		cmp.config.compare.recently_used,
		cmp.config.compare.score,
		cmp.config.compare.offset,
		cmp.config.compare.sort_text,
		cmp.config.compare.order,
	},
}

local get_buffers = function()
	local bufs = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		bufs[vim.api.nvim_win_get_buf(win)] = true
	end
	return vim.tbl_keys(bufs)
end

cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn['UltiSnips#Anon'](args.body)
		end,
	},
	window = window,
	mapping = mapping,
	sources = {
		{ name = 'nvim_lsp', priority = 9 },
		-- { name = 'cmp_tabnine', priority = 8, max_num_results = 3 },
		{ name = 'ultisnips', priority = 7, max_num_results = 6 },
		{
			name = 'buffer',
			priority = 7,
			option = {
				get_bufnrs = get_buffers,
			},
		},
	},
	sorting = sorting,
	completion = {
		completeopt = 'menu,menuone,noinsert',
	},
	formatting = {
		format = lspkind.cmp_format(),
	},
	experimental = {
		ghost_text = true,
	},
})

vim.cmd('autocmd! BufWritePost *.snippets CmpUltisnipsReloadSnippets')

vim.go.completeopt = 'menu,menuone,noselect'
