local M = {}

local statuscolumn = require('core.ui.statuscolumn')
local dashboard = require('alpha.themes.dashboard')
local separator_element = ' >  '

local make_button = function(button)
	if button.condition == 0 then
		return
	end

	local button_label = button.icon .. separator_element .. button.name

	return dashboard.button(button.key, button_label, button.cmd)
end

M.make_button_list = function(button_config)
	local buttons = {}

	for _, button in pairs(button_config) do
		local dashboard_button = make_button(button)

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
			vim.opt.showtabline = 0
			vim.opt.laststatus = 0
			vim.opt.ruler = false
			statuscolumn.hide_statuscolumn()
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
					vim.opt.showtabline = 2
					vim.opt.laststatus = 3
					vim.opt.ruler = true
					statuscolumn.show_statuscolumn()
				end,
			})
		end,
	})
end

M.build_footer = function()
	local vim = vim.version()
	local vim_formatted = string.format(' v%d.%d.%d', vim.major, vim.minor, vim.patch)
	return vim_formatted
end

return M
