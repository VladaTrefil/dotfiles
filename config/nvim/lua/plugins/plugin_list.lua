return {
	['lewis6991/impatient.nvim'] = {},

	['nvim-lua/plenary.nvim'] = {},

	['wbthomason/packer.nvim'] = {},

	['BurntSushi/ripgrep'] = {},

	['nvim-treesitter/nvim-treesitter'] = {
		build = ':TSUpdate',
		config = function()
			require('plugins.config.treesitter')
		end,
	},

	['kyazdani42/nvim-web-devicons'] = {
		config = function()
			require('nvim-web-devicons').setup()
		end,
	},

	['Shatur/neovim-session-manager'] = {
		config = function()
			require('plugins.config.session_manager')
		end,
	},

	['goolord/alpha-nvim'] = {
		commit = '89eaa18a472be680539dee5977e2255f4dbd0738',
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

	['rcarriga/nvim-notify'] = {
		requires = { 'kyazdani42/nvim-web-devicons', opt = true },
		config = function()
			require('plugins.config.notify')
		end,
	},

	['nvim-telescope/telescope.nvim'] = {
		tag = '0.1.0',
		requires = { 'nvim-lua/plenary.nvim' },
		config = function()
			require('plugins.config._telescope')
		end,
	},

	['nvim-telescope/telescope-fzf-native.nvim'] = {
		after = 'telescope.nvim',
		disable = vim.fn.executable('make') == 0,
		run = 'make',
		requires = { { 'nvim-telescope/telescope.nvim' } },
		config = function()
			require('plugins.config._telescope.utils').load_extension('fzf')
		end,
	},

	['debugloop/telescope-undo.nvim'] = {
		after = 'telescope.nvim',
		requires = { 'nvim-telescope/telescope.nvim' },
		config = function()
			require('plugins.config._telescope.utils').load_extension('undo')
		end,
	},

	['folke/which-key.nvim'] = {
		config = function()
			require('plugins.config.whichkey')
		end,
	},
	--
	['brooth/far.vim'] = {
		config = function()
			require('plugins.config.far')
		end,
	},

	['gelguy/wilder.nvim'] = {
		config = function()
			require('plugins.config.wilder')
		end,
	},

	['SirVer/ultisnips'] = {
		config = function()
			require('plugins.config.ultisnips')
		end,
	},

	['mhartington/formatter.nvim'] = {
		config = function()
			require('plugins.config.formatter')
		end,
	},

	['kdheepak/lazygit.nvim'] = {
		config = function()
			require('plugins.config.git').lazygit()
		end,
	},

	['kelly-lin/ranger.nvim'] = {
		config = function()
			require('plugins.config.ranger')
		end,
	},

	['zbirenbaum/copilot.lua'] = {
		cmd = 'Copilot',
		event = 'InsertEnter',
		config = function()
			require('plugins.config.copilot')
		end,
	},

	['~/Development/ChatGPT.nvim'] = {
		requires = {
			'MunifTanjim/nui.nvim',
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope.nvim',
		},
		config = function()
			require('plugins.config._chatgpt')
		end,
	},

	-- Package Manager
	['williamboman/mason.nvim'] = {
		build = ':MasonUpdate',
		config = function()
			require('plugins.config.lsp_tools.mason_conf')
		end,
	},

	['folke/neodev.nvim'] = {},

	-- Built-in LSP
	['neovim/nvim-lspconfig'] = {
		requires = {
			{ 'williamboman/mason.nvim' },
			{ 'williamboman/mason-lspconfig.nvim', as = 'mason-lspconfig' },
		},
		config = function()
			require('plugins.config.lsp_tools.neodev')
			require('plugins.config.lsp_tools.nvim_lspconfig')
		end,
	},

	-- Formatting and linting
	['jose-elias-alvarez/null-ls.nvim'] = {
		as = 'null-ls',
		after = 'nvim-lspconfig',
		requires = {
			{ 'williamboman/mason.nvim' },
			{ 'jay-babu/mason-null-ls.nvim', as = 'mason-null-ls' },
		},
		config = function()
			require('plugins.config.lsp_tools.null_ls')
		end,
	},

	['folke/trouble.nvim'] = {
		as = 'trouble',
		requires = {
			'neovim/nvim-lspconfig',
		},
	},

	-- VSCode like pictograms for menus, powered by Nvim LSP
	['onsails/lspkind.nvim'] = {},

	-- LSP symbols
	-- ['stevearc/aerial.nvim'] = {
	-- 	module = 'aerial',
	-- 	branch = 'nvim-0.5', -- for neovim 0.7
	-- 	after = { 'nvim-treesitter', 'nvim-lspconfig' },
	-- 	ft = { 'man', 'markdown' },
	-- 	config = function()
	-- 		require('plugins.config.aerial')
	-- 	end,
	-- },

	['hrsh7th/nvim-cmp'] = {
		-- after = 'lspkind.nvim',
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
	['zbirenbaum/copilot-cmp'] = {
		after = { 'copilot.lua' },
		config = function()
			require('plugins.config.cmp.copilot_cmp')
		end,
	},

	['tpope/vim-git'] = {},
	['tpope/vim-fugitive'] = {},
	['APZelos/blamer.nvim'] = {
		config = function()
			require('plugins.config.git').blamer()
		end,
	},

	['airblade/vim-gitgutter'] = {
		config = function()
			require('plugins.config.git').gitgutter()
		end,
	},

	['windwp/nvim-autopairs'] = {
		config = function()
			require('plugins.config.autopairs')
		end,
	},

	['rhysd/clever-f.vim'] = {},

	['tomtom/tcomment_vim'] = {},
	['lukas-reineke/indent-blankline.nvim'] = {
		config = function()
			require('plugins.config.indentline')
		end,
	},

	['RRethy/vim-illuminate'] = {}, -- " Highlights words that match the word under cursor
	['norcalli/nvim-colorizer.lua'] = {
		config = function()
			require('plugins.config._colorizer')
		end,
	},

	['tpope/vim-eunuch'] = {}, -- " File commands in vim

	['drzel/vim-repo-edit'] = {}, -- " Quickly clone github repo to tmp

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

	['m4xshen/hardtime.nvim'] = {
		requires = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
		config = function()
			require('plugins.config.hardtime')
		end,
	},
}
