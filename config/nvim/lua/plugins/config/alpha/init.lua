local present, alpha = pcall(require, 'alpha')

if not present then
	return
end

local dashboard = require('alpha.themes.dashboard')
local icons = require('core.icons')
local alpha_utils = require('plugins.config.alpha.utils')

local button_config = {
	{
		condition = pcall(require, 'session_manager'),
		key = 'i',
		icon = icons.Register,
		name = 'Restore last session',
		cmd = '<cmd> lua require("plugins.config.session_manager.utils").restore_session() <CR>',
	},
	{
		key = 'f',
		icon = icons.Search,
		name = 'Search directory',
		cmd = ':Telescope find_files<CR>',
	},
	{
		key = 'e',
		icon = icons.File,
		name = 'New file',
		cmd = ':ene <BAR> startinsert <CR>',
	},
	{
		key = 'r',
		icon = icons.Files,
		name = 'Recent',
		cmd = ':Telescope oldfiles<CR>',
	},
	{
		key = 's',
		icon = icons.Settings,
		name = 'Settings',
		cmd = ':e $MYVIMRC | :cd %:p:h | :wincmd k | :pwd<CR>',
	},
	{
		key = 'q',
		icon = icons.CloseCircle,
		name = 'Quit NVIM',
		cmd = ':qa<CR>',
	},
}

local header_str = {
	'                                                o8o                     ',
	'                                                `"\'                     ',
	'   ooo. .oo.    .ooooo.   .ooooo.  oooo    ooo oooo  ooo. .oo.  .oo.    ',
	'   `888P"Y88b  d88\' `88b d88\' `88b  `88.  .8\'  `888  `888P"Y88bP"Y88b   ',
	"    888   888  888ooo888 888   888   `88..8'    888   888   888   888   ",
	"    888   888  888    .o 888   888    `888'     888   888   888   888   ",
	"   o889o o888o `Y8bod8P' `Y8bod8P'     `8'     o888o o888o o888o o888o  ",
}

alpha_utils.setup_autocmds()

dashboard.section.header.val = header_str
dashboard.section.buttons.val = alpha_utils.build_button_list(button_config)

dashboard.section.header.opts = {
	position = 'center',
	hl = 'Blue',
}
dashboard.section.footer.opts = {
	position = 'center',
	hl = 'Blue',
}

local section = {
	header = dashboard.section.header,
	buttons = dashboard.section.buttons,
	footer = dashboard.section.footer,
}

local opts = {
	layout = {
		{ type = 'padding', val = 14 },
		section.header,
		{ type = 'padding', val = 6 },
		section.buttons,
		{ type = 'padding', val = 8 },
		section.footer,
	},
	opts = {
		margin = 5,
	},
}

alpha.setup(opts)
