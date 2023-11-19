local autopairs_ok, autopairs = pcall(require, 'nvim-autopairs')

if not autopairs_ok then
	return
end

autopairs.setup({
	check_ts = true,
	fast_wrap = {},
	disable_filetype = { 'TelescopePrompt', 'vim' },
	ts_config = {
		lua = { 'string' },
		javascript = { 'string', 'template_string' },
		java = false,
		ruby = { 'string' },
		slim = { 'string' },
	},
})

local cmp_ok, cmp = pcall(require, 'cmp')

if not cmp_ok then
	return
end

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
