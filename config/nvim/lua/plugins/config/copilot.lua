local copilot_ok, copilot = pcall(require, 'copilot')

if not copilot_ok then
	return
end

-- add function for automatic copilot authentication

copilot.setup({
	panel = {
		enabled = true,
		auto_refresh = false,
		keymap = {
			jump_prev = '<M-p>',
			jump_next = '<M-n>',
			accept = '<CR>',
			refresh = 'gr',
			-- open = '<M-o>',
		},
		layout = {
			position = 'bottom', -- | top | left | right
			ratio = 0.4,
		},
	},
	suggestion = {
		enabled = true,
		auto_trigger = true,
		debounce = 75,
		keymap = {
			accept = '<C-l>',
			accept_word = false,
			accept_line = false,
			next = '<C-n>',
			prev = '<C-p>',
			dismiss = '<C-x>',
		},
	},
	filetypes = {
		yaml = true,
		markdown = true,
		gitcommit = true,
		gitrebase = true,
		['.'] = false,
	},
})
