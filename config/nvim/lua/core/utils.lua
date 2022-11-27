local M = {}

local fn = vim.fn
local merge_tb = vim.tbl_deep_extend

M.load_mappings = function(section, mapping_opt)
	local function set_section_map(section_values)
		if section_values.plugin then
			return
		end
		section_values.plugin = nil

		for mode, mode_values in pairs(section_values) do
			if mode == 1 then
				mode = ''
			end

			local default_opts = merge_tb('force', { mode = mode }, mapping_opt or {})
			for keybind, mapping_info in pairs(mode_values) do
				-- merge default + user opts
				local opts = merge_tb('force', default_opts, mapping_info.opts or {})

				mapping_info.opts, opts.mode = nil, nil
				opts.desc = mapping_info[2]

				vim.keymap.set(mode, keybind, mapping_info[1], opts)
			end
		end
	end

	local mappings = require('core.mappings')

	if type(section) == 'string' then
		mappings[section]['plugin'] = nil
		mappings = { mappings[section] }
	end

	for _, sect in pairs(mappings) do
		set_section_map(sect)
	end
end

M.fold_label_text = function()
	local line = fn.getline(vim.v.foldstart)
	local text = fn.substitute(line, '#|"|-+|{+', '', '')

	local fold_size = vim.v.foldend - vim.v.foldstart
	local spacer_size = 96 - fn.len(text) - fn.len(fold_size)

	local spacer = fn['repeat']('.', spacer_size)

	return ' ' .. text .. spacer .. ' (' .. fold_size .. ' L)  '
end

M.is_cursor_inside_new_block = function()
	local line = fn.getline('.')
	local col = fn.col('.')
	local chars = string.sub(line, col - 2, col + 1)

	return chars:find('[{}-><-%[%]]') ~= nil
end

M.create_global_functions = function()
	function _G.ReloadConfig()
		for name, _ in pairs(package.loaded) do
			if name:match('^user') and not name:match('nvim-tree') then
				package.loaded[name] = nil
			end
		end

		dofile(vim.env.MYVIMRC)

		vim.notify('Nvim configuration reloaded!', vim.log.levels.INFO)
	end
end

return M
