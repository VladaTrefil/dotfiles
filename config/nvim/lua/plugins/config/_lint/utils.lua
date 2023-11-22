local M = {}

M.exec_lint = function(engine)
	local names = engine.linters_by_ft[vim.bo.filetype] or {}
	-- Use nvim-lint's logic first:
	-- * checks if linters exist for the full filetype first
	-- * otherwise will split filetype by "." and add all those linters
	-- * this differs from conform.nvim which only uses the first filetype that has a formatter
	names = engine._resolve_linter_by_ft(vim.bo.filetype)

	-- Add fallback linters.
	if #names == 0 then
		vim.list_extend(names, engine.linters_by_ft['_'] or {})
	end

	-- Add global linters.
	if engine.linters_by_ft['*'] then
		for _, linter in ipairs(engine.linters_by_ft['*']) do
			if not vim.tbl_contains(names, linter) then
				table.insert(names, linter)
			end
		end
	end

	-- Filter out linters that don't exist or don't match the condition.
	local ctx = { filename = vim.api.nvim_buf_get_name(0) }
	ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
	names = vim.tbl_filter(function(name)
		local linter = engine.linters[name]

		if not linter then
			vim.notify('Linter not found: ' .. name, vim.log.levels.WARN, { title = 'nvim-engine' })
		end

		local condition = linter.condition and not linter.condition(ctx)
		return linter and not (type(linter) == 'table' and condition)
	end, names)

	-- Run linters.
	if #names > 0 then
		engine.try_lint(names)
	end
end

M.debounce = function(ms, fn)
	local timer = vim.loop.new_timer()
	return function(...)
		local argv = { ... }
		timer:start(ms, 0, function()
			timer:stop()
			vim.schedule_wrap(fn)(unpack(argv))
		end)
	end
end

return M
