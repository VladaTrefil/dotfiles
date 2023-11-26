local cmp_ok, cmp = pcall(require, 'cmp')

if not cmp_ok then
	return
end

local config = require('plugins.config.cmp.options')

cmp.setup(config.editor_opts)
cmp.setup.cmdline({ '/', '?' }, config.search_opts)
cmp.setup.cmdline(':', config.cmd_opts)

vim.api.nvim_create_autocmd('BufWritePost', {
	pattern = '*.snippets',
	callback = function()
		vim.cmd('CmpUltisnipsReloadSnippets')
	end,
})

vim.api.nvim_create_augroup('lsp_diagnostics_hold', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorHold' }, {
	pattern = '*',
	group = 'lsp_diagnostics_hold',
	callback = function()
		local opts = {
			focusable = false,
			close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
			border = 'rounded',
			source = 'always',
			prefix = ' ',
			scope = 'cursor',
		}

		vim.diagnostic.open_float(opts)
	end,
})
