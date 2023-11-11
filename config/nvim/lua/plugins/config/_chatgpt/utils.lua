local M = {}

local mappings = require('plugins.config._chatgpt.mappings').window

M.make_help_text = function()
	local help_text = [[

    Welcome to ChatGPT.nvim!
    You can use the following keybindings:
  ]]

	local spacer = '\n    '

	for cmd, keybind in pairs(mappings) do
		local keybind_with_spaces = keybind .. string.rep(' ', 10 - #keybind)
		local text = keybind_with_spaces .. ' - ' .. cmd

		help_text = help_text .. spacer .. text
	end

	return help_text
end

return M
