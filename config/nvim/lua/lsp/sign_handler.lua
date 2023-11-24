local M = {}

-- Get a reference to the original signs handler
local orig_signs_handler = vim.diagnostic.handlers.signs

local placeholder_sign_name = 'DiagnosticSignPlaceholder'

local placeholder_sign_group = function(namespace)
	return namespace .. placeholder_sign_name
end

-- Get the most severe diagnostic per line
-- @param diagnostics - table of vim.diagnostics
-- @return table of vim.diagnostics
local find_most_severe = function(diagnostics)
	local max_severity_per_line = {}
	for _, d in pairs(diagnostics) do
		local m = max_severity_per_line[d.lnum]
		if not m or d.severity < m.severity then
			max_severity_per_line[d.lnum] = d
		end
	end

	return vim.tbl_values(max_severity_per_line)
end

-- Place a placeholder sign for each diagnostic
-- @param diagnostics - table of vim.diagnostics
-- @param namespace - diagnostic namespace
-- @param bufnr - buffer number
local place_placeholder_signs = function(diagnostics, namespace, bufnr)
	local sign_group = placeholder_sign_group(namespace)

	for _, d in pairs(diagnostics) do
		local opts = { lnum = d.lnum + 1, priority = 1 }
		vim.fn.sign_place(0, sign_group, placeholder_sign_name, bufnr, opts)
	end
end

local unplace_placeholder_signs = function(namespace, bufnr)
	local sign_group = placeholder_sign_group(namespace)
	vim.fn.sign_unplace(sign_group, { buffer = bufnr })
end

-- Define the placeholder sign
local define_placeholder_sign = function()
	local hl = placeholder_sign_name
	vim.fn.sign_define(placeholder_sign_name, { text = '  ', texthl = hl, numhl = hl })
end

-- Register a custom signs handler for diagnostics
M.register = function()
	define_placeholder_sign()

	-- Override the built-in signs handler
	vim.diagnostic.handlers.signs = {
		show = function(namespace, bufnr, ns_diagnostics, opts)
			local all_diagnostics = vim.diagnostic.get(bufnr)
			local filtered_diagnostics = find_most_severe(all_diagnostics)

			local diagnostics = vim.tbl_filter(function(d)
				return vim.tbl_contains(ns_diagnostics, d)
			end, filtered_diagnostics)

			unplace_placeholder_signs(namespace, bufnr)
			place_placeholder_signs(diagnostics, namespace, bufnr)

			orig_signs_handler.show(namespace, bufnr, diagnostics, opts)
		end,
		hide = function(namespace, bufnr)
			unplace_placeholder_signs(namespace, bufnr)
			orig_signs_handler.hide(namespace, bufnr)
		end,
	}
end

return M
