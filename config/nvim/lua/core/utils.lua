local M = {}

local fn = vim.fn
local merge_tb = vim.tbl_deep_extend
local register_name = vim.v.register

-- Counts number of lines in copy register
M.line_count_in_register = function()
	local register = fn.getreg(vim.v.register, nil, true)
	return vim.tbl_count(register)
end

-- true/false if line under the cursor is blank
M.is_line_blank = function()
	local line = fn.getline('.')
	return fn.match(line, '^\\s*$') == 0
end

M.register_ends_in_NL = function()
	local register = fn.getreg(vim.v.register)
	return fn.match(register, '\n$') > -1
end

-- true/false if copy register contains block of text
M.register_contains_block = function()
	local register_type = fn.getregtype(register_name)
	return register_type == 'V' and M.register_ends_in_NL()
end

-- makes string safe for nvim commands
M.termcodes = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- Capitalizes first letter of string
M.capitalize = function(str)
	return str:gsub('^%l', string.upper)
end

-- converts camelCase to snake_case and vice versa
M.convert_case = function(word)
	if word:find('[a-z][A-Z]') then
		return word:gsub('([a-z])([A-Z])', '%1_%2'):lower()
	elseif word:find('_[a-z]') then
		return word:gsub('(_)([a-z])', function(_, l)
			return l:upper()
		end)
	else
		return word
	end
end

-- Convert hex to rgb
M.hex2rgb = function(hex)
	local value = hex:gsub('#', '')
	return tonumber('0x' .. value:sub(1, 2)),
		tonumber('0x' .. value:sub(3, 4)),
		tonumber('0x' .. value:sub(5, 6))
end

-- Convert rgb to hex
M.rgb2hex = function(red, green, blue)
	return string.format('#%02x%02x%02x', red, green, blue)
end

M.set_highlights = function(highlights)
	for group, spec in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, spec)
	end
end

-- sets vim mappings from a table of mode/keybinds to commands
M.load_mappings = function(mapping_table, mapping_opt)
	for mode, mode_values in pairs(mapping_table) do
		if mode == 1 then
			mode = ''
		end

		for keybind, mapping_info in pairs(mode_values) do
			local opts = merge_tb('force', mapping_opt or {}, mapping_info.opts or {})
			local cmd = mapping_info[1]

			opts.desc = mapping_info[2]

			vim.keymap.set(mode, keybind, cmd, opts)
		end
	end
end

M.fold_label_text = function()
	local line = fn.getline(vim.v.foldstart)
	local text = fn.substitute(line, '#|"|-+|{+', '', '')

	local fold_size = vim.v.foldend - vim.v.foldstart
	local spacer_size = 96 - fn.len(text) - fn.len(fold_size)

	local spacer = vim.call('repeat', { '.', spacer_size })

	return ' ' .. text .. spacer .. ' (' .. fold_size .. ' L)  '
end

M.is_cursor_inside_new_block = function()
	local line = fn.getline('.')
	local col = fn.col('.')
	local chars = string.sub(line, col - 2, col + 1)

	return chars:find('[{}-><-%[%]]') ~= nil
end

M.paste_as_insert = function(reverse)
	local base = '<c-r><c-p>+<esc>'
	local before_cmd = ''
	local after_cmd = ''

	-- Register has linewise text
	if M.register_contains_block() then
		if reverse then
			before_cmd = 'O'
		else
			before_cmd = 'o'
		end

		local line_count = M.line_count_in_register()
		after_cmd = '"xdd' .. line_count .. 'k'
	-- Register has blockwise or charwise text
	else
		if M.is_line_blank() then
			before_cmd = '"xS'
		else
			if reverse then
				before_cmd = 'i'
			else
				before_cmd = 'a'
			end
		end
	end

	local keys = M.termcodes(before_cmd .. base .. after_cmd)
	vim.api.nvim_feedkeys(keys, 'n', false)
end

M.is_available = function(plugin)
	return packer_plugins ~= nil and packer_plugins[plugin] ~= nil
end

M.trigger_event = function(event)
	vim.schedule(function()
		vim.api.nvim_exec_autocmds('User', { pattern = 'Custom' .. event })
	end)
end

M.notify = function(msg, log, opts)
	if pcall(require, 'notify') then
		local default_opts = {
			title = 'log',
			timeout = 1000,
			animate = false,
		}

		local async = require('plenary.async')

		opts = merge_tb('force', default_opts, opts or {})
		log = log or vim.log.levels.INFO

		async.run(function()
			vim.notify.async(msg, log, opts)
		end, function() end)
	else
		vim.api.nvim_notify(msg, log, {})
	end
end

-- Expands xml tags to next lines
M.expand_xml_tags = function()
	vim.cmd([[%s/></>\r</ge]])
end

-- Auto indents entire file
M.autoindent = function()
	vim.fn.feedkeys("gg=G''")
end

-- Creates a directory if it doesn't exist
M.mkdir = function()
	local dir = fn.expand('<afile>:p:h')

	-- Create that directory (and its parents) if it doesn't exist yet
	if fn.isdirectory(dir) == 0 then
		fn.mkdir(dir, 'p')
	end
end

M.add_codespell_ignore_misspell = function()
	if not vim.fn.executable('codespell') then
		return
	end

	local file_path = vim.fn.expand('%:p')
	local output = vim.fn.execute('!codespell ' .. file_path)

	if output then
		-- print(vim.fn.match(output, '(^/.*:\\d:\\s*)\\@<=\\w*'))
		print(vim.fn.matchstr(output, '(/.*:\\d*:\\s*)\\@<=\\w*'))
	end
end

M.switch_case_line_under_cursor = function()
	local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
	local word = vim.fn.expand('<cword>')
	local word_start = vim.fn.matchstrpos(vim.fn.getline('.'), '\\k*\\%' .. (col + 1) .. 'c\\k*')[2]

	local word_with_converted_case = M.convert_case(word)

	vim.api.nvim_buf_set_text(
		0,
		line - 1,
		word_start,
		line - 1,
		word_start + #word,
		{ word_with_converted_case }
	)
end

M.convert_color_code = function(red, green, blue)
	vim.fn.feedkeys(M.termcodes('"9y'), 'nx')

	local selection = vim.fn.getreg('9')
	local value

	if selection:find('#') then
		local red, green, blue = M.hex2rgb(selection)
		value = string.format('%s,%s,%s', red, green, blue)
	elseif selection:find(',') then
		local red, green, blue = selection:match('(%d+),%s?(%d+),%s?(%d+)')
		value = M.rgb2hex(red, green, blue)
	else
		vim.notify('Invalid color code', vim.log.levels.ERROR, { title = 'Color Converter' })
		return
	end

	vim.fn.setreg('9', value)
	vim.fn.feedkeys(M.termcodes('gv"9p'), 'nx')
end

-- Clears neovim UI elements
M.clear_ui = function()
	-- clear search highlights
	vim.fn.feedkeys(M.termcodes('<cmd>noh<CR>'), 'nx')

	-- clear command line
	vim.fn.feedkeys(':', 'nx')

	-- dismiss any open notify messages
	vim.notify.dismiss()
end

return M
