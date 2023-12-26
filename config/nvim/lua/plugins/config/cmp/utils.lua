local M = {}

local icons = require('core.icons')
local utils = require('core.utils')

local MAX_INDEX_FILE_SIZE = 4000
local MAX_ITEM_WIDTH = 25

local source_icons = {
	copilot = icons.Github,
	nvim_lsp = icons.Stack,
	buffer = icons.File,
	nvim_lua = icons.Bomb,
	ultisnips = icons.Snippet,
	path = icons.Folder,
	cmdline = icons.Terminal,
	treesitter = icons.Treesitter,
}

-- Check if a buffer is loaded
-- @params bufnr number: The buffer number
-- return boolean: Whether the buffer is loaded
local is_loaded = function(bufnr)
	return vim.api.nvim_buf_is_loaded(bufnr)
end

-- Check if a buffer is valid to be indexed
-- @params bufnr number: The buffer number
-- return boolean: Whether the buffer is valid
local valid_size = function(bufnr)
	return vim.api.nvim_buf_line_count(bufnr) < MAX_INDEX_FILE_SIZE
end

-- Create a highlight group name for a items cmp source
-- @params source_name string: The source name
-- return string: The highlight group name
local menu_hl_group_name = function(source_name)
	local camel_case_source_name = utils.convert_case(source_name)
	local hl_group_name = utils.capitalize(camel_case_source_name)
	return 'CmpItemMenu' .. hl_group_name
end

-- Get currently opened valid buffers
-- return table: The list of valid buffers
M.get_buffers = function()
	local bufs = {}

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		-- Don't index giant files
		if is_loaded(bufnr) and valid_size(bufnr) then
			table.insert(bufs, bufnr)
		end
	end

	return bufs
end

-- Expend a completion item snippet
-- @params args table: The snippet args
M.expand_snippet = function(args)
	vim.fn['UltiSnips#Anon'](args.body)
end

-- Function to format the cmp completion item
-- @param entry table: The completion entry
-- @param item table: The completion item
-- return table: The formatted completion item
M.format_completion_item = function(entry, item)
	local item_with_kind = require('lspkind').cmp_format({
		mode = 'text',
		maxwidth = MAX_ITEM_WIDTH,
	})(entry, item)

	local source_icon = source_icons[entry.source.name] or ''
	local completion = string.sub(item_with_kind.abbr, 1, item_with_kind.maxwidth)

	local item_attrs = {
		menu_hl_group = menu_hl_group_name(entry.source.name),
		menu = string.format(' %s ', source_icon:gsub(' ', '')),
		abbr = string.format(' %s', completion),
		kind = string.format('  %s', item_with_kind.kind),
	}

	return vim.tbl_deep_extend('force', item_with_kind, item_attrs)
end

M.filter_lsp = function(entry, _)
	local kind = require('cmp.types.lsp').CompletionItemKind[entry:get_kind()]

	if kind == 'Text' then
		return false
	end

	return true
end

M.compare_underscore = function(entry1, entry2)
	local _, entry1_under = entry1.completion_item.label:find('^_+')
	local _, entry2_under = entry2.completion_item.label:find('^_+')
	entry1_under = entry1_under or 0
	entry2_under = entry2_under or 0
	return entry1_under < entry2_under
end

return M
