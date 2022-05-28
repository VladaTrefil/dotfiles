" Plugins:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Install Vim-Plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : "$XDG_CONFIG_HOME/nvim"
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Wilder
function! UpdateRemotePlugins(...)
  " Needed to refresh runtime files
  let &rtp=&rtp
  UpdateRemotePlugins
endfunction

call plug#begin('~/.config/nvim/plugged')
" Theme -------
Plug 'nvim-lualine/lualine.nvim'
Plug 'glepnir/dashboard-nvim'

" Tools -------
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'BurntSushi/ripgrep'
Plug 'brooth/far.vim'
Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'dense-analysis/ale'               " Linter and prettify
Plug 'SirVer/ultisnips'

" LSP -------
Plug 'prabirshrestha/vim-lsp'
Plug 'neovim/nvim-lspconfig'

" LSP -------
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'

" Git -------
Plug 'tpope/vim-git'
Plug 'tpope/vim-fugitive'
Plug 'SirJson/fzf-gitignore'
Plug 'airblade/vim-gitgutter'
Plug 'APZelos/blamer.nvim'              " git blame

" Syntax/Languages -------
Plug 'posva/vim-vue'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'jelera/vim-javascript-syntax'
Plug 'cakebaker/scss-syntax.vim'
Plug 'wavded/vim-stylus'
Plug 'GutenYe/json5.vim'
Plug 'elzr/vim-json'
Plug 'jasonshell/vim-svg-indent'
Plug 'vim-scripts/svg.vim'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-haml'
Plug 'kchmck/vim-coffee-script'
Plug 'slim-template/vim-slim'
Plug 'leafgarland/typescript-vim', {'for': ['typescript', 'typescript.tsx'] }
Plug 'mboughaba/i3config.vim'

" Enhancements -------
Plug 'rhysd/clever-f.vim'               " Improves commands f, F, t and T
Plug 'easymotion/vim-easymotion'        " Improves vim movement
Plug 'tomtom/tcomment_vim'
Plug 'Yggdroot/indentLine'
Plug 'RRethy/vim-illuminate'            " Highlights words that match the word under cursor
Plug 'chrisbra/Colorizer'
Plug 'tpope/vim-eunuch'                 " File commands in vim
Plug 'psliwka/vim-smoothie'             " Smooth scroll
Plug 'drzel/vim-repo-edit'              " Quickly clone github repo to tmp
Plug 'ryanoasis/vim-devicons'
Plug 'jez/vim-superman'                 " Man pages in vim
Plug 'jiangmiao/auto-pairs'
Plug 'onsails/lspkind.nvim'             " VSCode like pictograms for menus, powered by Nvim LSP

call plug#end()

source ~/.config/nvim/plugins/palette.vim

if exists("g:palette")
  source ~/.config/nvim/plugins/theme.vim
end

if exists("plugs['nvim-cmp']")
  source ~/.config/nvim/plugins/cmp.vim
end

if exists("plugs['wilder.nvim']")
  source ~/.config/nvim/plugins/wilder.vim
end

if exists("plugs['dashboard-nvim']")
  source ~/.config/nvim/plugins/dashboard.vim
end

if exists("plugs['indentLine']")
  source ~/.config/nvim/plugins/indentline.vim
end

if exists("plugs['fzf.vim']")
  source ~/.config/nvim/plugins/fzf.vim
end

if exists("plugs['far.vim']")
  source ~/.config/nvim/plugins/far.vim
end

if exists("plugs['ale']")
  source ~/.config/nvim/plugins/ale.vim
end

if exists("plugs['colorizer']")
  source ~/.config/nvim/plugins/colorizer.vim
end

if exists("plugs['vim-gitgutter']")
  source ~/.config/nvim/plugins/gitgutter.vim
end

if exists("plugs['lualine.nvim']")
  source ~/.config/nvim/plugins/lualine.lua
end

if exists("plugs['ultisnips']")
  source ~/.config/nvim/plugins/ultisnips.vim
end

if exists("plugs['vim-lsp']")
  source ~/.config/nvim/plugins/lsp.vim
end
