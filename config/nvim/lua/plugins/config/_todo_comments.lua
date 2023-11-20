local todo_comments_ok, todo_comments = pcall(require, 'todo-comments')

if not todo_comments_ok then
	vim.notify('plugin not found', vim.log.levels.ERROR, {
		title = 'Todo Comments',
	})

	return
end

local icons = require('core.icons')
local utils = require('core.utils')

-- can be a hex color, or a named color
local colors = {
	info = 'info',
	hint = 'hint',
	warning = 'warning',
	error = 'error',
}

todo_comments.setup({
	keywords = {
		FIX = {
			icon = icons.Bug:gsub('%s', ''),
			color = colors.error,
			-- a set of other keywords that all map to this FIX keywords
			alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' },
			-- signs = false, -- configure signs for some keywords individually
		},
		TODO = { icon = icons.Checkmark:gsub('%s', ''), color = colors.info },
		HACK = { icon = icons.Fire:gsub('%s', ''), color = colors.warning },
		WARN = {
			icon = icons.Warning:gsub('%s', ''),
			color = colors.warning,
			alt = { 'WARNING', 'XXX' },
		},
		PERF = {
			icon = icons.Performance:gsub('%s', ''),
			color = colors.warning,
			alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' },
		},
		NOTE = {
			icon = icons.Note:gsub('%s', ''),
			color = colors.hint,
			alt = { 'INFO' },
		},
		TEST = {
			icon = icons.Test:gsub('%s', ''),
			color = colors.test,
			alt = { 'TESTING', 'PASSED', 'FAILED' },
		},
	},

	colors = {
		error = { 'DiagnosticError', 'ErrorMsg' },
		warning = { 'DiagnosticWarn', 'WarningMsg' },
		info = { 'DiagnosticInfo' },
		hint = { 'DiagnosticHint' },
		default = { 'Identifier' },
	},

	-- regex that will be used to match keywords.
	-- don't replace the (KEYWORDS) placeholder
	highlight = {
		pattern = [[#?.*<(KEYWORDS)\s*]],
	},
	search = {
		pattern = [[\b(KEYWORDS)\b]],
	},
})
