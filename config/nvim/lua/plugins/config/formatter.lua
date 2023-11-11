local present, formatter = pcall(require, 'formatter')

if not present then
  return
end

-- Utilities for creating configurations
local util = require('formatter.util')

local function prettier()
  return {
    exe = 'prettier',
    args = {
      '--semi false',
      '--single-quote true',
      '--print-width 120',
      vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
    },
    stdin = true,
  }
end

local function rubocop()
  return {
    exe = 'bundle exec rubocop',
    args = {
      '--config "$XDG_CONFIG_HOME/rubocop/rubocop.yml"',
      '--fix-layout',
      '--stdin',
      util.escape_path(util.get_current_buffer_file_name()),
      '--format',
      'files',
    },
    stdin = true,
    transform = function(text)
      table.remove(text, 1)
      if vim.fn.match(text[1], '=') == 0 then
        table.remove(text, 1)
      end
      return text
    end,
  }
end

local function stylua()
  return {
    exe = 'stylua',
    args = {
      '--config-path "$XDG_CONFIG_HOME/stylua/stylua.toml"',
      '--stdin-filepath',
      util.escape_path(util.get_current_buffer_file_path()),
      '--',
      '-',
    },
    stdin = true,
  }
end

formatter.setup({
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = {
    -- typescriptreact = { prettier },
    -- typescript = { prettier },
    -- javascript = { prettier },
    -- markdown = { prettier },
    html = { prettier },
    css = { prettier },
    scss = { prettier },
    yaml = { prettier },
    ruby = { rubocop },
    lua = { stylua },
  },
  -- any file
  ['*'] = {
    require('formatter.filetypes.any').remove_trailing_whitespace,
  },
})

vim.api.nvim_exec(
  [[
  augroup FormatAutogroup
    autocmd!
    autocmd BufWritePost * FormatWrite
  augroup END
]] ,
  false
)
