local M = {}

local plugin_utils = require('plugins.config._chatgpt.utils')
local icons = require('core.icons')

M.texts = {
	sessions_window = {
		top = ' Sessions ',
	},
	popup_window = {
		top = ' ChatGPT ',
	},
	system_window = {
		top = ' SYSTEM ',
	},
	popup_input = {
		top = ' Prompt ',
	},
	settings_window = {
		top = ' Settings ',
	},
	chat = {
		welcome_message = plugin_utils.make_help_text(),
		loading_text = 'Loading, please wait ...',
	},
}

M.popup_layout = {
	default = 'center',
	center = {
		width = '80%',
		height = '80%',
	},
	right = {
		width = '30%',
		width_settings_open = '50%',
	},
}

M.popup_window = {
	border = {
		highlight = 'PmenuBorder',
		style = 'single',
		text = {
			top_align = 'center',
			top = M.texts.popup_window.top,
		},
	},
	win_options = {
		wrap = true,
		linebreak = true,
		winblend = 10,
	},
	buf_options = {
		filetype = 'markdown',
	},
	focusable = true,
	zindex = 50,
}

M.system_window = {
	border = {
		highlight = 'ChatGPTSystemBorder',
		style = 'single',
		text = {
			top_align = 'center',
			top = M.texts.system_window.top,
		},
	},
	win_options = {
		wrap = true,
		linebreak = true,
	},
}

M.popup_input = {
	prompt = icons.Prompt,
	border = {
		highlight = 'ChatGPTInputBorder',
		style = 'single',
		text = {
			top_align = 'center',
			top = M.texts.popup_input.top,
		},
	},
	win_options = {
		wrap = true,
	},
	submit = '<C-Enter>',
	submit_n = '<Enter>',
	max_visible_lines = 20,
	focusable = true,
	zindex = 50,
}

M.settings_window = {
	setting_sign = icons.Settings,
	selected_highlight = 'OrangeBold',
	border = {
		highlight = 'ChatGPTSettingsBorder',
		style = 'single',
		text = {
			top_align = 'center',
			top = M.texts.settings_window,
		},
	},
}

M.sessions_window = {
	active_highlight = 'OrangeBold',
	border = {
		highlight = 'ChatGPTSessionsBorder',
		style = 'single',
		text = {
			top_align = 'center',
			top = M.texts.sessions_window,
		},
	},
}

return M
