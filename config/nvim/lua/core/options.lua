local fn = vim.fn
local opt = vim.opt
local g = vim.g

g.mapleader = ' '

opt.list = true
opt.listchars:append('space:⋅')
opt.listchars:append('eol:↴')

opt.signcolumn = 'yes:2'

-- Enable popup transparency
opt.pumblend = 15

-- Display line numbers
opt.number = true
opt.relativenumber = true

-- Highlight search
opt.hlsearch = true

-- Search ignore case when no capital letters
opt.ignorecase = true
opt.smartcase = true

-- search as you type
opt.incsearch = true

-- show substitute as you type
opt.inccommand = 'nosplit'

opt.directory = opt.directory ^ { '$HOME/.vim/tmp//' }

-- opt.clipboard to system clipboard
opt.clipboard = 'unnamedplus'

opt.swapfile = false

-- Enable mouse control for resizing panes
opt.mouse = 'a'

--Disable safe write for webpack compilation
opt.backupcopy = 'yes'

opt.smartindent = true

-- Offopt.from end of window to start scrolling
opt.scrolloff = 10

-- Enable setting vim options in files (vim: opt.ft='sh')
opt.modeline = true

-- Enable current line hightlight
opt.cursorline = true

-- Automaticaly reload changed files
opt.autoread = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Dont wrap
opt.wrap = false

-- Use spaces instead of tabs.
opt.expandtab = true

-- Be smart using tabs ;)
opt.smarttab = true

-- One tab == four spaces.
opt.shiftwidth = 2

-- One tab == four spaces.
opt.tabstop = 2

-- Fix typescript redraw exceeded
opt.re = 0

-- improve scrolling performance when navigating through large results
opt.lazyredraw = true

-- use old regexp engine
opt.regexpengine = 1

-- Folds
opt.foldmethod = 'marker'
opt.foldtext = 'v:lua.foldtext()'
opt.fillchars = 'fold:|,eob: '
opt.foldenable = true

if opt.encoding:get() == 'latin1' and fn.has('gui_running') then
  opt.encoding = 'utf-8'
end

if opt.listchars:get() == 'eol:$' then
  opt.listchars = 'tab:> ,trail:-,extends:>,precedes:<,nbsp:+'
end

if vim.v.version > 703 or vim.v.version == 703 and fn.has('patch541') then
  -- Delete comment character when joining commented lines
  opt.formatoptions:append('j')
end

-------------------------------------------------------------------------------------------------------
-- Disable default plugins: {{{

local default_plugins = {
  '2html_plugin',
  'getscript',
  'getscriptPlugin',
  'gzip',
  'logipat',
  'netrw',
  'netrwPlugin',
  'netrwSettings',
  'netrwFileHandlers',
  'matchit',
  'tar',
  'tarPlugin',
  'rrhelper',
  'spellfile_plugin',
  'vimball',
  'vimballPlugin',
  'zip',
  'zipPlugin',
  'tutor',
  'rplugin',
  'syntax',
  'synmenu',
  'optwin',
  'compiler',
  'bugreport',
  'ftplugin',
}

for _, plugin in pairs(default_plugins) do
  g['loaded_' .. plugin] = 1
end

-- }}}
-------------------------------------------------------------------------------------------------------
