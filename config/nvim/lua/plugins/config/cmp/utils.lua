local M = {}

local cmp = require('cmp')

local icons = require('core.icons')
local utils = require('core.utils')

local MAX_INDEX_FILE_SIZE = 4000
local MAX_ITEM_WIDTH = 25

local source_labels = {
	copilot = icons.Github,
	nvim_lsp = icons.Stack,
	buffer = icons.File,
	nvim_lua = icons.Bomb,
	ultisnips = icons.Snippet,
	path = icons.Folder,
	cmdline = icons.Terminal,
}

local is_loaded = function(bufnr)
	return vim.api.nvim_buf_is_loaded(bufnr)
end

local valid_size = function(bufnr)
	return vim.api.nvim_buf_line_count(bufnr) < MAX_INDEX_FILE_SIZE
end

local menu_hl_group_name = function(source_name)
	local camel_case_source_name = utils.convert_case(source_name)
	local hl_group_name = utils.capitalize(camel_case_source_name)
	return 'CmpItemMenu' .. hl_group_name
end

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

M.expand_snippet = function(args)
	vim.fn['UltiSnips#Anon'](args.body)
end

M.format_selection_item = function(entry, item)
	local item_with_kind = require('lspkind').cmp_format({
		mode = 'text',
		maxwidth = MAX_ITEM_WIDTH,
	})(entry, item)

	local item_attrs = {
		menu = source_labels[entry.source.name] or '',
		menu_hl_group = menu_hl_group_name(entry.source.name),
		abbr = ' ' .. string.sub(item_with_kind.abbr, 1, item_with_kind.maxwidth),
		kind = '  ' .. item_with_kind.kind,
	}

	return vim.tbl_deep_extend('force', item_with_kind, item_attrs)
end

return M
