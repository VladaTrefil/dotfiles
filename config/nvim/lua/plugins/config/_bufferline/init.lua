local present, bufferline = pcall(require, 'bufferline')

if not present then
	return
end

local utils = require('core.utils')
local theme = require('plugins.config._bufferline.theme')

utils.set_highlights(theme)

-- show only buffers with window open on current tab
local tab_buffers_filter = function(bufnr)
	local winid = vim.fn.win_findbuf(bufnr)[1]
	local tabnr = vim.fn.win_id2tabwin(winid)[1]

	local current_tabnr = vim.fn.tabpagenr()

	if tabnr == current_tabnr then
		return true
	end
end

bufferline.setup({
	options = {
		custom_filter = tab_buffers_filter,
	},
})
