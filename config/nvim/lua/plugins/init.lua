local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

local present, packer = pcall(require, 'packer')

if not present then
	return
end

packer.startup(function(use)
	use('lewis6991/impatient.nvim')

	use({ 'nvim-lua/plenary.nvim', module = 'plenary' })

	use('wbthomason/packer.nvim')

	use('BurntSushi/ripgrep')

	use({ 'nvim-treesitter/nvim-treesitter' })

	use({
		'kyazdani42/nvim-web-devicons',
		config = function()
			require('plugins.config.others').devicons()
		end,
	})

	use({
		'tiagovla/scope.nvim',
		config = function()
			require('plugins.config.others').scope()
		end,
	})

	use({
		'goolord/alpha-nvim',
		config = function()
			require('plugins.config.alpha')
		end,
	})

	use({
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true },
		config = function()
			require('plugins.config.lualine')
		end,
	})

	use({
		'akinsho/bufferline.nvim',
		tag = 'v2.*',
		config = function()
			require('plugins.config.bufferline')
		end,
	})

	use({
		'nvim-telescope/telescope.nvim',
		tag = '0.1.0',
		requires = { { 'nvim-lua/plenary.nvim' } },
		config = function()
			require('plugins.config.telescope')
		end,
	})

	use({
		'brooth/far.vim',
		config = function()
			require('plugins.config.others').far()
		end,
	})

	use({
		'gelguy/wilder.nvim',
		config = function()
			require('plugins.config.wilder')
		end,
	})

	use({
		'SirVer/ultisnips',
		config = function()
			require('plugins.config.others').ultisnips()
		end,
	})

	use({
		'mhartington/formatter.nvim',
		config = function()
			require('plugins.config.formatter')
		end,
	})

	use({
		'kdheepak/lazygit.nvim',
		config = function()
			require('plugins.config.others').lazygit()
		end,
	})

	use({
		'hrsh7th/cmp-nvim-lsp',
		config = function()
			require('plugins.config.cmp')
		end,
	})

	use('hrsh7th/cmp-nvim-lua')
	use('hrsh7th/cmp-buffer')
	use('hrsh7th/cmp-path')
	use('David-Kunz/cmp-npm')
	use('hrsh7th/nvim-cmp')
	use('quangnguyen30192/cmp-nvim-ultisnips')

	use('tpope/vim-git')
	use('tpope/vim-fugitive')
	use('APZelos/blamer.nvim')

	use('onsails/lspkind.nvim') -- VSCode like pictograms for menus, powered by Nvim LSP
	use('jose-elias-alvarez/typescript.nvim')

	use({
		'airblade/vim-gitgutter',
		config = function()
			require('plugins.config.others').gitgutter()
		end,
	})

	use('rhysd/clever-f.vim')
	use('easymotion/vim-easymotion')
	use('tomtom/tcomment_vim')
	use('lukas-reineke/indent-blankline.nvim')

	use('RRethy/vim-illuminate') -- " Highlights words that match the word under cursor
	use('chrisbra/Colorizer')

	use('tpope/vim-eunuch') -- " File commands in vim

	use('psliwka/vim-smoothie') -- " Smooth scroll

	use('drzel/vim-repo-edit') -- " Quickly clone github repo to tmp

	use('jiangmiao/auto-pairs')
	use('mattn/emmet-vim')

	use('HerringtonDarkholme/yats.vim')
	use('wavded/vim-stylus')
	use('GutenYe/json5.vim')
	use('elzr/vim-json')
	use('jasonshell/vim-svg-indent')
	use('vim-scripts/svg.vim')
	use('mboughaba/i3config.vim')
	use('elkowar/yuck.vim')

	use('pangloss/vim-javascript')
	use('kchmck/vim-coffee-script')

	use('vim-ruby/vim-ruby')
	use('tpope/vim-rails')
	use('skalnik/vim-vroom')
	use('slim-template/vim-slim')

	if packer_bootstrap then
		require('packer').sync()
	end

	-- vim.api.nvim_create_autocmd('User', {
	--   pattern = 'PackerComplete',
	--   callback = function()
	--     vim.cmd('silent! MasonInstallAll') -- close packer window
	--     require('packer').loader('nvim-treesitter')
	--   end,
	-- })
end)
