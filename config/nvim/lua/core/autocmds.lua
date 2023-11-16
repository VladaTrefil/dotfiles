local autocmd = vim.api.nvim_create_autocmd
local opt = vim.opt

local utils = require('core.utils')

autocmd('BufWinEnter', {
	pattern = '*.snippets',
	callback = function()
		opt.foldmethod = 'marker'
		opt.foldlevel = 0
	end,
})

autocmd({ 'BufNewFile', 'BufRead' }, {
	pattern = '*.tsx,*.jsx',
	callback = function()
		opt.filetype = 'typescript.typescriptreact'
	end,
})

autocmd({ 'FocusGained', 'BufEnter', 'BufWritePost' }, {
	desc = 'Refresh buffer',
	pattern = '*',
	callback = function()
		if not opt.buftype:get() then
			vim.api.nvim_command('checktime')
		end
	end,
})

autocmd('BufWritePost', {
	pattern = vim.fn.expand('$HOME/config/nvim/*'),
	callback = function()
		vim.fn.source(vim.env.MYVIMRC)
	end,
})

autocmd({ 'BufRead', 'BufNewFile' }, {
	desc = 'Auto format xml buffer',
	pattern = '*.xml',
	callback = function()
		utils.expand_xml_tags()
		utils.autoindent()
		utils.notify('File formatted', vim.log.levels.INFO, { title = 'XML Autoindent' })
	end,
})

autocmd({ 'BufWritePre', 'FileWritePre' }, {
	desc = 'Auto mkdir for missing directory',
	pattern = '*',
	callback = function()
		utils.mkdir()
	end,
})

-- Syntax
autocmd({ 'BufRead', 'BufNewFile' }, {
	desc = 'Init rasi syntax',
	pattern = '*.rasi',
	callback = require('syntax.rasi'),
})

autocmd({ 'BufWritePre' }, {
	desc = 'Autoformat',
	pattern = '*.yuck,*.xml,*.sh',
	callback = function()
		utils.autoindent()
	end,
})

-- local function match_redundant_spaces()
--   vim.fn.matchadd('RedundantSpaces', '\\s\\+$')
-- end
--
-- vim.api.nvim_create_autocmd('BufWinEnter,InsertEnter,InsertLeave', {
--   desc = 'Match redundant spaces',
--   pattern = '*/*',
--   callback = match_redundant_spaces
-- })
