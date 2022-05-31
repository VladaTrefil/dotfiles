"      ___    ___ ___   _____   
"     /'___\/' __` __`\/\ '__`\ 
"    /\ \__//\ \/\ \/\ \ \ \L\ \
"    \ \____\ \_\ \_\ \_\ \ ,__/
"     \/____/\/_/\/_/\/_/\ \ \/ 
"                         \ \_\ 
"                          \/_/ 


set completeopt=menu,menuone,noselect

autocmd! BufWritePost *.snippets CmpUltisnipsReloadSnippets

lua <<EOF
  local cmp = require'cmp'
  local lspkind = require('lspkind')
  local nvim_lsp = require('lspconfig')

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
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'ultisnips' }, -- For ultisnips users.
      { name = 'buffer' },
    }),
    completion = {
      completeopt = 'menu,menuone,noinsert'
    },
    formatting = {
      format = lspkind.cmp_format(),
    },
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()) --nvim-cmp
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- Setup lspconfig.
  -- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  nvim_lsp['solargraph'].setup{
    cmd = {'solargraph'},
    on_attach = on_attach,
    capabilities = capabilities,
  }
EOF
