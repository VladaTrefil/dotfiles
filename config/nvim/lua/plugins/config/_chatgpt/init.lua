local chatgpt_ok, chatgpt = pcall(require, 'chatgpt')

if not chatgpt_ok then
	vim.notify("ChatGPT lua package doesn't exist", vim.log.levels.ERROR)
	return
end

local utils = require('core.utils')
local icons = require('core.icons')

local window_options = require('plugins.config._chatgpt.window_options')
local mappings = require('plugins.config._chatgpt.mappings')
local highlights = require('plugins.config._chatgpt.theme')

chatgpt.setup({
	openai_params = {
		model = 'gpt-3.5-turbo',
		frequency_penalty = 0,
		presence_penalty = 0,
		max_tokens = 600,
		temperature = 0,
		top_p = 1,
		n = 1,
	},

	chat = {
		welcome_message = window_options.texts.chat.welcome_message,
		loading_text = window_options.texts.chat.loading_text,
		sessions_window = window_options.sessions_window,
		keymaps = mappings.window,
		question_sign = icons.Person:gsub('%s', ''),
		answer_sign = icons.Robot:gsub('%s', ''),
		border_left_sign = '',
		border_right_sign = '',
		max_line_length = 120,
	},

	use_openai_functions_for_edits = false,
	actions_paths = {},
	show_quickfixes_cmd = 'Trouble quickfix',
	predefined_chat_gpt_prompts = 'https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv',

	main_window = {
		winhighlight = 'Normal:Pmenu,FloatBorder:PmenuBorder',
	},

	popup_layout = window_options.popup_layout,
	popup_window = window_options.popup_window,
	system_window = window_options.system_window,
	popup_input = window_options.popup_input,
	settings_window = window_options.settings_window,
})

utils.load_mappings(mappings.base)
utils.set_highlights(highlights)
