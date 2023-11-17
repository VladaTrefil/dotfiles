local fn = vim.fn
local opt = vim.opt
local g = vim.g

g.mapleader = ' '

opt.timeoutlen = 2000

-- Performance
opt.redrawtime = 1500
opt.updatetime = 100
opt.lazyredraw = true -- improve scrolling performance

-- Display line numbers
opt.number = true
opt.relativenumber = true
opt.signcolumn = 'yes:2'

-- Dont show mode indicator in command line
opt.showmode = false

-- Enable current line highlight
opt.cursorline = true

-- Highlight search
opt.hlsearch = true
-- search as you type
opt.incsearch = true
-- show substitute as you type
opt.inccommand = 'nosplit'

-- Search ignore case when no capital letters
opt.ignorecase = true
opt.smartcase = true

-- opt.clipboard to system clipboard
opt.clipboard = 'unnamedplus'

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.expand('$XDG_STATE_HOME/nvim/undodir/')
opt.directory = opt.directory ^ { vim.fn.expand('$XDG_STATE_HOME/nvim/tmp/') }

-- Enable mouse control for resizing panes
opt.mouse = 'a'

-- Use spaces instead of tabs.
opt.expandtab = true
-- Be smart using tabs ;)
opt.smarttab = true
-- One tab == four spaces.
opt.shiftwidth = 2
-- One tab == four spaces.
opt.tabstop = 2

opt.smartindent = true

-- Start scrolling 10 lines from the edge of window
opt.scrolloff = 10

-- Enable setting vim options in files (vim: opt.ft='sh')
opt.modeline = true

-- Automatically reload changed files
opt.autoread = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Dont wrap
opt.wrap = false

-- Fix typescript redraw exceeded
opt.re = 0

-- use old regexp engine
opt.regexpengine = 1

-- Folds
opt.foldmethod = 'marker'
opt.foldtext = 'v:lua.foldtext()'
opt.fillchars:append('fold:|,eob: ')
opt.foldenable = true

opt.matchpairs = { '(:)', '{:}', '[:]', '<:>' }

opt.encoding = 'utf-8'

opt.list = true
opt.listchars:append('space:⋅')
opt.listchars:append('eol:↴')

if opt.listchars:get() == 'eol:$' then
	opt.listchars:append('tab:> ,trail:-,extends:>,precedes:<,nbsp:+')
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
