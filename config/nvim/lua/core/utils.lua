local M = {}

local fn = vim.fn
local merge_tb = vim.tbl_deep_extend

local session_dir = "~/.local/state/nvim/sessions"

M.load_mappings = function(mapping_table, mapping_opt)
  for mode, mode_values in pairs(mapping_table) do
    if mode == 1 then
      mode = ''
    end

    for keybind, mapping_info in pairs(mode_values) do
      -- print(mode)
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

	local spacer = fn['repeat']('.', spacer_size)

	return ' ' .. text .. spacer .. ' (' .. fold_size .. ' L)  '
end

M.is_cursor_inside_new_block = function()
	local line = fn.getline('.')
	local col = fn.col('.')
	local chars = string.sub(line, col - 2, col + 1)

	return chars:find('[{}-><-%[%]]') ~= nil
end

M.buffer_is_empty = function()
	return vim.fn.line('$') == 1 and vim.fn.getline(1) == ''
end

M.trigger_event = function(event)
	vim.schedule(function()
		vim.api.nvim_exec_autocmds('User', { pattern = 'Custom' .. event })
	end)
end

M.is_available = function(plugin)
	return packer_plugins ~= nil and packer_plugins[plugin] ~= nil
end

return M
