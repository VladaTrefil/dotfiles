local M = {}

local fn = vim.fn
local merge_tb = vim.tbl_deep_extend
local register_name = vim.v.register

-- Counts number of lines in copy register
M.line_count_in_register = function ()
  local register = fn.getreg(vim.v.register, nil, true)
  return vim.tbl_count(register)
end

-- true/false if line under the cursor is blank
M.is_line_blank = function()
  local line = fn.getline('.')
  return fn.match(line, '^\\s*$') == 0
end

-- makes string safe for nvim commands
M.termcodes = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

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

M.paste_width_indent = function(reverse)
  local base = '<c-r><c-p>+<esc>'
  local before_cmd = ''
  local after_cmd = ''

  -- Register has linewise text
  if fn.getregtype(register_name) == 'V' then
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

M.notify = function(message)
  print(message)
end

-- Expands xml tags to next lines
M.expand_xml_tags = function()
  vim.cmd([[%s/></>\r</ge]])
end

-- Reindents entire file
M.reindent = function()
  vim.fn.feedkeys('gg=G')
  M.notify('file formatted')
end

-- Creates a directory if it doesn't exist
M.mkdir = function()
	local dir = fn.expand("<afile>:p:h")

	-- Create that directory (and its parents) if it doesn't exist yet
	if fn.isdirectory(dir) == 0 then
		fn.mkdir(dir, "p")
  end
end

return M
