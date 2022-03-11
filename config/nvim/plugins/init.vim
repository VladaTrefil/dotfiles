" Plugins:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Install Vim-Plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
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
Plug 'VladaTrefil/vim-theme'

" Tools -------
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'BurntSushi/ripgrep'               " For CocSearch
Plug 'brooth/far.vim'
Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Git -------
Plug 'tpope/vim-git'
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
Plug 'dense-analysis/ale'               " Linter and prettify
Plug 'Yggdroot/indentLine'
Plug 'RRethy/vim-illuminate'            " Highlights words that match the word under cursor
Plug 'chrisbra/Colorizer'
Plug 'tpope/vim-eunuch'                 " File commands in vim
Plug 'psliwka/vim-smoothie'           " Smooth scroll
Plug 'drzel/vim-repo-edit'              " Quickly clone github repo to tmp
Plug 'glepnir/dashboard-nvim'
Plug 'ryanoasis/vim-devicons'
Plug 'jez/vim-superman'                 " Man pages in vim
Plug 'nvim-lualine/lualine.nvim'

call plug#end()

source ~/.config/nvim/plugins/wilder.vim
source ~/.config/nvim/plugins/dashboard.vim
source ~/.config/nvim/plugins/indentline.vim
source ~/.config/nvim/plugins/fzf.vim
source ~/.config/nvim/plugins/coc.vim
source ~/.config/nvim/plugins/far.vim
source ~/.config/nvim/plugins/ale.vim
source ~/.config/nvim/plugins/colorizer.vim
source ~/.config/nvim/plugins/gitgutter.vim
source ~/.config/nvim/plugins/lualine.lua
