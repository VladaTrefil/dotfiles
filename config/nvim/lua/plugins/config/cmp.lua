local present, cmp = pcall(require, 'cmp')

if not present then
  return
end

local lspkind = require('lspkind')

local ELLIPSIS_CHAR = '…'
local MAX_LABEL_WIDTH = 25

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

local mappings_config = require('core.mappings').cmp_api(cmp)
local mapping = cmp.mapping.preset.insert(mappings_config)

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

local format = function(_, item)
  local content = item.abbr

  local abbr = (" "):rep(MAX_LABEL_WIDTH - #content)

  if #content > MAX_LABEL_WIDTH then
    item.abbr = vim.fn.strcharpart(content, 0, MAX_LABEL_WIDTH) .. ELLIPSIS_CHAR
  else
    item.abbr = content .. abbr
  end

  return item
end

local get_buffers = function()
  local bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    bufs[vim.api.nvim_win_get_buf(win)] = true
  end
  return vim.tbl_keys(bufs)
end

local sources = {
  { name = 'nvim_lsp', priority = 9 },
  { name = 'ultisnips', priority = 9, max_num_results = 4 },
  {
    name = 'buffer',
    priority = 8,
    option = {
      get_bufnrs = get_buffers,
    },
  }
}

local expandSnippet = function(args)
  vim.fn['UltiSnips#Anon'](args.body)
end

cmp.setup({
  snippet = {
    expand = expandSnippet,
  },
  window = window,
  mapping = mapping,
  sources = sources,
  sorting = sorting,
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  formatting = {
    format = format
  },
  experimental = {
    ghost_text = {},
  },
})

vim.cmd('autocmd! BufWritePost *.snippets CmpUltisnipsReloadSnippets')

vim.go.completeopt = 'menu,menuone,noselect'
