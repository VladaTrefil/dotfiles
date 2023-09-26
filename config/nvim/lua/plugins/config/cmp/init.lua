local present, cmp = pcall(require, 'cmp')

if not present then
  return
end

local cmp_utils = require('plugins.config.cmp.utils')

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

local sources = {
  { name = 'nvim_lsp', priority = 9 },
  { name = 'ultisnips', priority = 9, max_num_results = 4 },
  { name = 'copilot', priority = 2 },
  {
    name = 'buffer',
    priority = 8,
    option = {
      get_bufnrs = cmp_utils.get_buffers,
    },
  },
}

local mappings_config = require('core.mappings').cmp_api(cmp)

cmp.setup({
  window = window,
  mapping = cmp.mapping.preset.insert(mappings_config),
  sources = sources,
  sorting = sorting,
  completion = {
    completeopt = 'menu,menuone',
  },
  snippet = {
    expand = cmp_utils.expand_snippet,
  },
  formatting = {
    format = cmp_utils.format_selection_item,
  },
  experimental = {
    ghost_text = {},
  },
})

vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*.snippets',
  callback = function()
    vim.cmd('CmpUltisnipsReloadSnippets')
  end,
})

vim.go.completeopt = 'menu,menuone,noselect'
