local bootstraped = require('plugins.bootstrap')
local packer_ok, packer = pcall(require, 'packer')

if not packer_ok then
	vim.notify("Packer lua package doesn't exist ")
	return
end

local plugins = require('plugins.plugin_list')

local stdpath = vim.fn.stdpath
local default_compile_path = stdpath('data') .. '/packer_compiled.lua'

packer.startup({
	function(use)
		for key, plugin in pairs(plugins) do
			if type(key) == 'string' and not plugin[1] then
				plugin[1] = key
			end

			use(plugin)
		end

		if bootstraped then
			packer.sync()
		end

		-- add binaries installed by mason.nvim to path
		vim.env.PATH = vim.env.PATH .. ':' .. stdpath('data') .. '/mason/bin'

		-- load compiled plugins path if exists
		local compiled_file, _ = loadfile(default_compile_path)
		if compiled_file then
			compiled_file()
		end
	end,
	config = {
		compile_path = default_compile_path,
		ensure_dependencies = true,
		profile = {
			enable = true,
			threshold = 0.0001,
		},
		git = {
			clone_timeout = 300,
			subcommands = {
				update = 'pull --rebase',
			},
		},
		auto_clean = true,
		compile_on_sync = true,
	},
})

vim.defer_fn(function()
	vim.api.nvim_exec_autocmds('User', { pattern = 'PackLoad' })
end, 10)
