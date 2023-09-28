local present, cmp = pcall(require, 'cmp')

if not present then
  return
end

local _, copilot_cmp_comparators = pcall(require, 'copilot_cmp.comparators')
local cmp_utils = require('plugins.config.cmp.utils')
local format = require('plugins.config.cmp.format')
local mappings_config = require('core.mappings').cmp_api(cmp)

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

local sources = {
  { name = 'ultisnips', priority = 1000 },
  { name = 'copilot', priority = 900 },
  { name = 'nvim_lsp', priority = 750 },
  { name = 'buffer', priority = 500, option = { get_bufnrs = cmp_utils.get_buffers } },
  { name = 'path', priority = 250 },
}

local sort = {
  comparators = {
    copilot_cmp_comparators.prioritize or function() end,
    cmp.config.compare.exact,
    cmp.config.compare.locality,
    cmp.config.compare.score,
    cmp.config.compare.recently_used,
    cmp.config.compare.offset,
    cmp.config.compare.sort_text,
    cmp.config.compare.order,
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
    fields = { 'abbr', 'kind', 'menu' },
    format = format.format_selection_item,
  },
  mapping = cmp.mapping.preset.insert(mappings_config),
  completion = {
    completeopt = completeopt,
  },
  experimental = {
    ghost_text = {},
  },
  performance = {
    max_view_entries = 60,
  },
})

vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*.snippets',
  callback = function()
    vim.cmd('CmpUltisnipsReloadSnippets')
  end,
})

vim.go.completeopt = completeopt
