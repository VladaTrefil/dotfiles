return {
	['lewis6991/impatient.nvim'] = {},

	['nvim-lua/plenary.nvim'] = { module = 'plenary' },

	['wbthomason/packer.nvim'] = {},

	['BurntSushi/ripgrep'] = {},

	['nvim-treesitter/nvim-treesitter'] = {},

	['kyazdani42/nvim-web-devicons'] = {
		config = function()
			require('plugins.config.others').devicons()
		end,
	},

	['tiagovla/scope.nvim'] = {
		config = function()
			require('plugins.config.others').scope()
		end,
	},

	['goolord/alpha-nvim'] = {
		config = function()
			require('plugins.config.alpha')
		end,
	},

	['nvim-lualine/lualine.nvim'] = {
		requires = { 'kyazdani42/nvim-web-devicons', opt = true },
		config = function()
			require('plugins.config.lualine')
		end,
	},

	['akinsho/bufferline.nvim'] = {
		tag = 'v2.*',
		config = function()
			require('plugins.config.bufferline')
		end,
	},

	['nvim-telescope/telescope.nvim'] = {
		tag = '0.1.0',
		requires = { { 'nvim-lua/plenary.nvim' } },
		config = function()
			require('plugins.config.telescope').core_config()
		end,
	},

	['nvim-telescope/telescope-fzf-native.nvim'] = {
		after = 'telescope.nvim',
		disable = vim.fn.executable('make') == 0,
		run = 'make',
		config = function()
			require('plugins.config.telescope').fzf_config()
		end,
	},

	['brooth/far.vim'] = {
		config = function()
			require('plugins.config.others').far()
		end,
	},

	['gelguy/wilder.nvim'] = {
		config = function()
			require('plugins.config.wilder')
		end,
	},

	['SirVer/ultisnips'] = {
		config = function()
			require('plugins.config.others').ultisnips()
		end,
	},

	['mhartington/formatter.nvim'] = {
		config = function()
			require('plugins.config.formatter')
		end,
	},

	['kdheepak/lazygit.nvim'] = {
		config = function()
			require('plugins.config.others').lazygit()
		end,
	},

	-- Built-in LSP
	['neovim/nvim-lspconfig'] = {
		module = 'lspconfig',
		config = function()
			require('plugins.config.lspconfig')
		end,
	},

	-- Formatting and linting
	['jose-elias-alvarez/null-ls.nvim'] = {
		module = 'null-ls',
		config = function()
			require('plugins.config.null-ls')
		end,
	},

	-- Package Manager
	['williamboman/mason.nvim'] = {
		module = 'mason',
		cmd = {
			'Mason',
			'MasonInstall',
			'MasonUninstall',
			'MasonUninstallAll',
			'MasonLog',
			'MasonUpdate', -- astronvim command
			'MasonUpdateAll', -- astronvim command
		},
		config = function()
			require('plugins.config.mason').setup_core()
		end,
	},

	-- LSP manager
	['williamboman/mason-lspconfig.nvim'] = {
		after = 'nvim-lspconfig',
		config = function()
			require('plugins.config.mason').setup_lspconfig()
		end,
	},

	-- null-ls manager
	['jayp0521/mason-null-ls.nvim'] = {
		after = 'null-ls.nvim',
		config = function()
			require('plugins.config.mason').setup_null_ls()
		end,
	},

	-- LSP symbols
	['stevearc/aerial.nvim'] = {
		module = 'aerial',
		branch = 'nvim-0.5', -- for neovim 0.7
		after = { 'nvim-treesitter', 'nvim-lspconfig' },
		ft = { 'man', 'markdown' },
		config = function()
			require('plugins.config.aerial')
		end,
	},

	['hrsh7th/nvim-cmp'] = {
		config = function()
			require('plugins.config.cmp')
		end,
	},

	['hrsh7th/cmp-nvim-lsp'] = {},
	['hrsh7th/cmp-nvim-lua'] = {},
	['hrsh7th/cmp-buffer'] = {},
	['hrsh7th/cmp-path'] = {},
	['David-Kunz/cmp-npm'] = {},
	['quangnguyen30192/cmp-nvim-ultisnips'] = {},

	['tpope/vim-git'] = {},
	['tpope/vim-fugitive'] = {},
	['APZelos/blamer.nvim'] = {},
	['onsails/lspkind.nvim'] = {}, -- VSCode like pictograms for menus, powered by Nvim LSP

	['airblade/vim-gitgutter'] = {
		config = function()
			require('plugins.config.others').gitgutter()
		end,
	},

	['rhysd/clever-f.vim'] = {},
	['easymotion/vim-easymotion'] = {},
	['tomtom/tcomment_vim'] = {},
	['lukas-reineke/indent-blankline.nvim'] = {},

	['RRethy/vim-illuminate'] = {}, -- " Highlights words that match the word under cursor
	['chrisbra/Colorizer'] = {},

	['tpope/vim-eunuch'] = {}, -- " File commands in vim

	['psliwka/vim-smoothie'] = {}, -- " Smooth scroll

	['drzel/vim-repo-edit'] = {}, -- " Quickly clone github repo to tmp

	['jiangmiao/auto-pairs'] = {},
	['mattn/emmet-vim'] = {},

	['HerringtonDarkholme/yats.vim'] = {},
	['wavded/vim-stylus'] = {},
	['GutenYe/json5.vim'] = {},
	['elzr/vim-json'] = {},
	['jasonshell/vim-svg-indent'] = {},
	['vim-scripts/svg.vim'] = {},
	['mboughaba/i3config.vim'] = {},
	['elkowar/yuck.vim'] = {},

	['pangloss/vim-javascript'] = {},
	['kchmck/vim-coffee-script'] = {},
	['jose-elias-alvarez/typescript.nvim'] = {},

	['vim-ruby/vim-ruby'] = {},
	['tpope/vim-rails'] = {},
	['skalnik/vim-vroom'] = {},
	['slim-template/vim-slim'] = {},
}
