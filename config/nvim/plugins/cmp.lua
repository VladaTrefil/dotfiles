--                                   --|
--      ___    ___ ___   _____       --|
--     /'___\/' __` __`\/\ '__`\     --|
--    /\ \__//\ \/\ \/\ \ \ \L\ \    --|
--    \ \____\ \_\ \_\ \_\ \ ,__\    --|
--     \/____/\/_/\/_/\/_/\ \ \/     --|
--                         \ \_\     --|
--                          \/_/     --|


vim.cmd "autocmd! BufWritePost *.snippets CmpUltisnipsReloadSnippets"

vim.go.completeopt = "menu,menuone,noselect"

local cmp = require'cmp'
local lspkind = require('lspkind')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
  window = {
    documentation = {
      border = "rounded",
      winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
    },
    completion = {
      border = "rounded",
      winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
    }
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = {
    { name = 'nvim_lsp', priority = 9 },
    -- { name = 'cmp_tabnine', priority = 8, max_num_results = 3 },
    { name = 'ultisnips' , priority = 7, max_num_results = 6 },
    { name = 'buffer', priority = 7 },
  },
  sorting = {
    comparators = {
      cmp.config.compare.exact,
      cmp.config.compare.locality,
      cmp.config.compare.recently_used,
      cmp.config.compare.score,
      cmp.config.compare.offset,
      cmp.config.compare.sort_text,
      cmp.config.compare.order,
    },
  },
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  formatting = {
    format = lspkind.cmp_format(),
  },
  experimental = {
    ghost_text = true,
  },
})
