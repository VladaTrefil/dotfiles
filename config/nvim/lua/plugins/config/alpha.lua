local present, alpha = pcall(require, 'alpha')

if not present then
  return
end

local dashboard = require('alpha.themes.dashboard')

-- Set header
dashboard.section.header.val = {
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '                                             o8o                     ',
  '                                             `"\'                     ',
  'ooo. .oo.    .ooooo.   .ooooo.  oooo    ooo oooo  ooo. .oo.  .oo.    ',
  '`888P"Y88b  d88\' `88b d88\' `88b  `88.  .8\'  `888  `888P"Y88bP"Y88b   ',
  " 888   888  888ooo888 888   888   `88..8'    888   888   888   888   ",
  " 888   888  888    .o 888   888    `888'     888   888   888   888   ",
  "o888o o888o `Y8bod8P' `Y8bod8P'     `8'     o888o o888o o888o o888o  ",
  '',
  '',
  '',
}

local build_session_button = function()
  local sm_utils = require('plugins.config.session_manager.utils')

  if not sm_utils then
    return
  end

  function _G.RestoreLastSession()
    sm_utils.restore_session()
  end

  local restore_cmd = [[<cmd> lua RestoreLastSession() <cr>]]
  return dashboard.button('i', '  > Restore last session', restore_cmd)
end

-- Set menu
dashboard.section.buttons.val = {
  build_session_button(),
  dashboard.button('f', '  > Search directory', ':Telescope find_files<CR>'),
  dashboard.button('e', '  > New file', ':ene <BAR> startinsert <CR>'),
  dashboard.button('r', '  > Recent', ':Telescope oldfiles<CR>'),
  dashboard.button('s', '  > Settings', ':e $MYVIMRC | :cd %:p:h | :wincmd k | :pwd<CR>'),
  dashboard.button('q', '  > Quit NVIM', ':qa<CR>'),
}

alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'alpha',
  callback = function()
    vim.opt_local.foldenable = false
  end,
})
