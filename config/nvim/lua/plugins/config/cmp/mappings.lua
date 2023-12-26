local M = {}

local cmp = require('cmp')

local on_confirm = function(fallback)
	if cmp.visible() then
		cmp.confirm({ select = true })
	elseif vim.fn['UltiSnips#CanJumpForwards']() ~= 0 then
		vim.fn['UltiSnips#JumpForwards']()
	else
		fallback()
	end
end

local on_confirm_inverse = function(fallback)
	if vim.fn['UltiSnips#CanJumpBackwards']() ~= 0 then
		vim.fn['UltiSnips#JumpBackwards']()
	else
		fallback()
	end
end

local common = {
	-- add function for switch between docs and completion
	['<C-n>'] = vim.NIL,
	['<C-p>'] = vim.NIL,
	['<C-u>'] = cmp.mapping.scroll_docs(-4),
	['<C-d>'] = cmp.mapping.scroll_docs(4),
	['<C-e>'] = cmp.mapping(cmp.mapping.abort(), { 'i', 'c', 's' }),
	['<Tab>'] = cmp.mapping(on_confirm, { 'i', 'c', 's' }),
	['<S-Tab>'] = cmp.mapping(on_confirm_inverse, { 'i', 's' }),
}

M.editor = vim.tbl_deep_extend('force', common, {
	['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c', 's' }),
	['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c', 's' }),
})

M.cmdline = vim.tbl_deep_extend('force', common, {
	['<C-j>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c', 's' }),
	['<C-k>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c', 's' }),
})

return M
