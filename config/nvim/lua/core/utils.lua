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

M.paste_as_insert_reverse = function()
  M.paste_as_insert(true)
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

-- Reindents entire file
M.reindent = function()
  vim.fn.feedkeys('gg=G')
end

-- Creates a directory if it doesn't exist
M.mkdir = function()
  local dir = fn.expand('<afile>:p:h')

  -- Create that directory (and its parents) if it doesn't exist yet
  if fn.isdirectory(dir) == 0 then
    fn.mkdir(dir, 'p')
  end
end

return M
