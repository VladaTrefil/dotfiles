local cmp = require('cmp')
local cmp_utils = require('plugins.config.cmp.utils')

return {
	-- add function for switch between docs and completion
	['<C-u>'] = cmp.mapping.scroll_docs(-4),
	['<C-d>'] = cmp.mapping.scroll_docs(4),
	['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c', 's' }),
	['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c', 's' }),
	['<C-e>'] = cmp.mapping(cmp.mapping.abort(), { 'i', 'c', 's' }),
	['<Tab>'] = cmp.mapping(cmp_utils.on_confirm, { 'i', 's' }),
	['<S-Tab>'] = cmp.mapping(cmp_utils.on_confirm_inverse, { 'i', 's' }),
}
