-- IndentLine Settings:
---------------------------------------------------------------

vim.opt.list = true
vim.opt.listchars:append('space:⋅')
vim.opt.listchars:append('eol:↴')

require('indent_blankline').setup({
  space_char_blankline = ' ',
  -- show_current_context = true,
  -- show_current_context_start = true,
  -- use_treesitter_scope = true,
  -- context_char_list = { '┃', '║', '╬', '█' },
  buftype_exclude = { 'terminal' },
  filetype_exclude = { 'dashboard' },
})
