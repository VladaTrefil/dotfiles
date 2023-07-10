-- Initalize
local utils = require('core.utils')
local plugins = require('plugins.plugin_list')

local stdpath = vim.fn.stdpath

-- add binaries installed by mason.nvim to path
-- vim.env.PATH = vim.env.PATH .. ':' .. stdpath('data') .. '/mason/bin'

local default_compile_path = stdpath('data') .. '/packer_compiled.lua'

-- try loading packer
local packer_path = stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
local packer_available = vim.fn.empty(vim.fn.glob(packer_path)) == 0

-- if packer isn't availble, reinstall it
if not packer_available then
	-- set the location to install packer
	-- delete the old packer install if one exists
	vim.fn.delete(packer_path, 'rf')
	-- clone packer
	vim.fn.system({
		'git',
		'clone',
		'--depth',
		'1',
		'https://github.com/wbthomason/packer.nvim',
		packer_path,
	})

	-- add packer and try loading it
	vim.cmd('packadd packer.nvim')

	local packer_loaded, _ = pcall(require, 'packer')
	packer_available = packer_loaded

	-- if packer didn't load, print error
	if not packer_available then
		vim.api.nvim_err_writeln('Failed to load packer at:' .. packer_path)
	end
end

-- if packer is available, check if there is a compiled packer file
if packer_available then
	-- try to load the packer compiled file
	local run_me, _ = loadfile(default_compile_path)

	if run_me then
		-- if the file loads, run the compiled function
		run_me()
	else
		-- if there is no compiled file, ask user to sync packer
		-- require('plugins')

		vim.api.nvim_create_autocmd('User', {
			once = true,
			pattern = 'PackerComplete',
			callback = function()
				vim.cmd.bw()
				-- vim.tbl_map(require, { 'nvim-treesitter', 'mason' })
				-- astronvim.notify('Mason is installing packages if configured, check status with :Mason')
			end,
		})

		vim.opt.cmdheight = 1
		vim.notify('Please wait while plugins are installed...')
		vim.cmd('PackerSync()')
	end
end

local packer = require('packer')

packer.startup({
	function(use)
		for key, plugin in pairs(plugins) do
			if type(key) == 'string' and not plugin[1] then
				plugin[1] = key
			end

			use(plugin)
		end
	end,
	config = {
		compile_path = default_compile_path,
    log = { level = 'debug' },
		display = {
			open_fn = function()
				return require('packer.util').float({ border = 'rounded' })
			end,
		},
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
