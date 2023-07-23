vim.cmd("highlight clear")

if vim.fn.exists "syntax_on" then vim.cmd("syntax reset") end

vim.o.background = "dark"
vim.o.termguicolors = true

local base = { "base", "highlight_groups" }
local plugins = { 'telescope', 'lualine', 'easymotion', 'cmp', 'gitgutter', 'indentline', 'bufferline' }
local syntax = { 'base', 'lua', 'vim', 'javascript', 'java', 'json', 'ruby', 'xml', 'css', 'html', 'markdown' }

local highlights = {}

for _, module in ipairs(base) do
  highlights = vim.tbl_deep_extend("force", highlights, require("theme." .. module))
end

for _, module in ipairs(plugins) do
  highlights = vim.tbl_deep_extend("force", highlights, require("theme.plugins." .. module))
end

for _, module in ipairs(syntax) do
  highlights = vim.tbl_deep_extend("force", highlights, require("theme.syntax." .. module))
end

for group, spec in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, spec)
end
