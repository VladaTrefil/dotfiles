local colorizer_ok, colorizer = pcall(require, 'colorizer')

if not colorizer_ok then
	return
end

local mappings = require('plugins.config._colorizer.mappings')
require('core.utils').load_mappings(mappings)

local general_options = {
	RGB = true, -- #RGB hex codes
	RRGGBB = true, -- #RRGGBB hex codes
	RRGGBBAA = true, -- #RRGGBBAA hex codes
	names = false, -- "Name" codes like Blue
	mode = 'background', -- Set the display mode.
}

local filetype_options = {
	filetypes = {
		'*',
		css = {
			rgb_fn = true, -- CSS rgb() and rgba() functions
			hsl_fn = true, -- CSS hsl() and hsla() functions
			css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
			css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
		},
	},
}

colorizer.setup(filetype_options, general_options)

-- local autocmd_group = 'Colorizer'
-- vim.api.nvim_create_augroup(autocmd_group, { clear = true })
-- vim.api.nvim_create_autocmd('BufRead', {
-- 	group = autocmd_group,
-- 	pattern = '*',
-- 	callback = function()
-- 		vim.defer_fn(function()
-- 			require('colorizer').attach_to_buffer(0)
-- 		end, 0)
-- 	end,
-- })
