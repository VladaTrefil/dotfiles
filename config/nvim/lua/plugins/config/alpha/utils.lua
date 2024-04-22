local M = {}

local utils = require('core.utils')
local dashboard = require('alpha.themes.dashboard')
local separator_element = ' >  '

M.build_button_list = function(button_config)
	local buttons = {}

	for _, button in pairs(button_config) do
		if button.condition == 0 then
			return
		end

		local button_label = button.icon .. separator_element .. button.name
		local dashboard_button = dashboard.button(button.key, button_label, button.cmd)

		if dashboard_button then
			table.insert(buttons, dashboard_button)
		end
	end

	return buttons
end

M.setup_autocmds = function()
	vim.api.nvim_create_augroup('alpha_tabline', { clear = true })

	vim.api.nvim_create_autocmd('FileType', {
		group = 'alpha_tabline',
		pattern = 'alpha',
		callback = function()
			utils.disable_ui()
		end,
	})

	vim.api.nvim_create_autocmd('FileType', {
		group = 'alpha_tabline',
		pattern = 'alpha',
		callback = function()
			vim.api.nvim_create_autocmd('BufUnload', {
				group = 'alpha_tabline',
				buffer = 0,
				callback = function()
					utils.enable_ui()
				end,
			})
		end,
	})
end

return M
