local M = {}

local load_mappings = require('core.utils').load_mappings

M.autopairs = function()
  local present1, autopairs = pcall(require, 'nvim-autopairs')
  local present2, cmp = pcall(require, 'cmp')

  if not (present1 and present2) then
    return
  end

  local options = {
    fast_wrap = {},
    disable_filetype = { 'TelescopePrompt', 'vim' },
  }

  autopairs.setup(options)

  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end

M.blankline = function()
  local present, blankline = pcall(require, 'indent_blankline')

  if not present then
    return
  end

  local options = {
    indentLine_enabled = 1,
    filetype_exclude = {
      'help',
      'terminal',
      'alpha',
      'packer',
      'lspinfo',
      'TelescopePrompt',
      'TelescopeResults',
      'mason',
      'dashboard',
      '',
    },
    buftype_exclude = { 'terminal' },
    show_trailing_blankline_indent = false,
    show_first_indent_level = false,
    show_current_context = true,
    show_current_context_start = true,
  }

  blankline.setup(options)
end

M.colorizer = function()
  local present, colorizer = pcall(require, 'colorizer')

  if not present then
    return
  end

  local options = {
    filetypes = {
      '*',
    },

    user_default_options = {
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      names = false, -- "Name" codes like Blue
      RRGGBBAA = false, -- #RRGGBBAA hex codes
      rgb_fn = false, -- CSS rgb() and rgba() functions
      hsl_fn = false, -- CSS hsl() and hsla() functions
      css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
      css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
      mode = 'background', -- Set the display mode.
    },
  }

  colorizer.setup(options)
  -- execute colorizer as soon as possible
  vim.defer_fn(function()
    require('colorizer').attach_to_buffer(0)
  end, 0)
end

M.devicons = function()
  local present, devicons = pcall(require, 'nvim-web-devicons')
  if present then
    devicons.setup()
  end
end

M.scope = function()
  local present, scope = pcall(require, 'scope')
  if present then
    scope.setup()
  end
end

M.far = function()
  vim.cmd([[
    let g:far#source='rgnvim'
    let g:far#ignore_files=["~/.config/nvim/farignore"]
    let g:far#preview_window_height=20
    let g:far#limit=200
    let g:far#default_file_mask = '*'
  ]])
end

M.ultisnips = function()
  vim.g.UltiSnipsSnippetDirectories = { vim.fn.stdpath('config') .. '/ultisnips' }
end

M.lazygit = function()
  vim.keymap.set('n', '<Leader>gg', '<cmd>LazyGit<cr>')

  vim.g.lazygit_floating_window_winblend = 1
  vim.g.lazygit_floating_window_use_plenary = 1
end

M.gitgutter = function()
  vim.cmd([[
    let g:gitgutter_sign_added = '\ +'
    let g:gitgutter_sign_modified = '\ ~'
    let g:gitgutter_sign_removed = '\ -'
    let g:gitgutter_sign_removed_first_line = '\ -'
    let g:gitgutter_sign_removed_above_and_below = '\ -'
    let g:gitgutter_sign_modified_removed = '\ ~'
  ]])
end

M.blamer = function()
  local mappings = require('core.mappings').blamer
  load_mappings(mappings)
end


return M
