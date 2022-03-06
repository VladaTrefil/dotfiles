set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugged: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')
" Plug 'wellle/targets.vim'
" Plug 'ap/vim-css-color'
" Plug 'pechorin/any-jump.vim'
" Plug 'editorconfig/editorconfig-vim'
" Plug 'mattn/emmet-vim'
" Plug 'tpope/vim-fugitive'
" Plug 'christoomey/vim-conflicted'
" Plug 'ryanoasis/vim-devicons'
" Plug 'junegunn/vim-easy-align'
" junegunn/vim-peekaboo

" Wilder
function! UpdateRemotePlugins(...)
  " Needed to refresh runtime files
  let &rtp=&rtp
  UpdateRemotePlugins
endfunction

" Tools -------
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'BurntSushi/ripgrep'               " For CocSearch
Plug 'brooth/far.vim'
Plug 'jez/vim-superman'                 " Man pages in vim
Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }

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

" Theme -------
Plug 'VladaTrefil/vim-theme'
call plug#end()

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" let g:skip_defaults_vim = 1

set path+=**					" Searches current directory recursively.
set number relativenumber       " Display line numbers

" Highlight search
set hlsearch
" Search ignore case
set ignorecase smartcase  " ignore case only when the pattern contains no capital letters
" search as you type
set incsearch
" show substitute as you type
set inccommand=nosplit

set directory^=$HOME/.vim/tmp//

" Set clipboard to system clipboard
set clipboard=unnamedplus

set noswapfile

" Folding on marker
set foldmethod=marker

" Enable mouse control for resizing panes
set mouse=a

"Disable safe write for webpack compilation
set backupcopy=yes

" Offset from end of window to start scrolling
set scrolloff=10

" Enable setting vim options in files
set modeline

" source vimrc when saving any vim file
autocmd! BufWritePost .vimrc source $MYVIMRC

autocmd BufWinLeave .vimrc mkview
autocmd BufWinEnter .vimrc silent loadview 

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Theme Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" colorscheme gruvbox

if exists("plugs['vim-theme']")
  colorscheme ayu
end

set tabline=%!TabLine()

function TabLine()
  let s = '%#TabLine#'
  let s .= '%='
  let s .= '%#TabLineFill#%T'

	for i in range(tabpagenr('$'))
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

	  " set the tab page number (for mouse clicks)
	  let s .= '%' . (i + 1) . 'T' . (i + 1) . "  "
  endfor

  let s .= '%#TabLine#'
  let s .= "%=%999Xﮊ  "

  return s
endfunction

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Wilder Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call wilder#setup({
  \ 'modes': [':', '/', '?'],
  \ 'next_key': '<C-p>',
  \ 'previous_key': '<C-n>'
  \ })


call wilder#set_option('renderer', wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
      \ 'highlighter': wilder#basic_highlighter(),
      \ 'min_width': '30%',
      \ 'max_height': '30%',
      \ 'reverse': '1',
      \ 'highlights': {
      \   'border': 'Blue',
      \   'default': 'Normal',
      \   'accent': 'Normal',
      \   'selected': 'Red',
      \ },
      \ 'pumblend': 10,
      \ 'left': [
      \   ' ', wilder#popupmenu_devicons(),
      \ ],
      \ 'right': [
      \   ' ', wilder#popupmenu_scrollbar(),
      \ ],
      \ })))


" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Dashboard Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ascii: {{{

" \  '   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀        ',
" \  '   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⡾⠿⢿⡀⠀⠀⠀⠀⣠⣶⣿⣷⠀⠀⠀⠀        ',
" \  '   ⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣦⣴⣿⡋⠀⠀⠈⢳⡄⠀⢠⣾⣿⠁⠈⣿⡆⠀⠀⠀        ',
" \  '   ⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⠿⠛⠉⠉⠁⠀⠀⠀⠹⡄⣿⣿⣿⠀⠀⢹⡇⠀⠀⠀        ',
" \  '   ⠀⠀⠀⠀⠀⣠⣾⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⣰⣏⢻⣿⣿⡆⠀⠸⣿⠀⠀⠀        ',
" \  '   ⠀⠀⠀⢀⣴⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣆⠹⣿⣷⠀⢘⣿⠀⠀⠀        ',
" \  '   ⠀⠀⢀⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⠋⠉⠛⠂⠹⠿⣲⣿⣿⣧          ',
" \  '   ⠀⢠⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣿⣿⣿⣷⣾⣿⡇⢀⠀⣼⣿⣿⣿⣧         ',
" \  '   ⠰⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⡘⢿⣿⣿⣿         ',
" \  '   ⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣷⡈⠿⢿⣿         ',
" \  '   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠁⢙⠛⣿⣿⣿⣿⡟⠀⡿⠀⠀⢀⣿⡇        ',
" \  '   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣶⣤⣉⣛⠻⠇⢠⣿⣾⣿⡄⢻⡇        ',

" ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠤⠴⠶⠶⠤⣄⣀⣀⣀⣀⡴⠛⡶⠦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⠴⢊⠕⠊⠉⠉⠉⠢⡘⠀⠀⠀⠀⠀⠀⠑⣔⣚⣣⡀⣀⠀⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⠴⠖⠋⠁⠀⠀⠻⣟⣋⣙⠻⠥⠞⠁⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⢳⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠖⠛⠉⠀⢀⡔⠋⠉⡤⠤⠔⠒⠒⠒⠐⠚⠛⠛⠛⠛⠓⠒⠒⠲⠤⠤⠤⠤⠔⡲⠚⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⠀⠀⠀⠀⣠⡴⠚⠉⠀⠀⠀⠀⠀⠈⠳⠦⠔⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⠀⠀⢠⡞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⠀⣼⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⣼⠁⠀⢀⣠⠤⠶⠶⠶⠶⠶⢤⡀⠀⠀⠀⠀⠀⢠⡘⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠤⠭⣲⡦⡴⢾⡟⠁⠀⠀⠀⠀
" ⠀⠀⠀⡇⠀⣼⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⢳⡀⠀⠀⠀⠀⠙⢦⣙⣄⣀⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⡏⠀⠀⠀⣿⡼⠲⠽⠆⠀⠀⠀⠀
" ⠀⠀⠰⡇⢰⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣳⠀⠀⠀⠀⠀⠀⣯⢬⠱⣟⠁⠀⠀⠀⠀⠀⠀⠀⣸⢤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠃⠀⠀⠀⠀⠀⠀⠁⠈⠓⠚⠀⠀⠀⠀⠀⠀⠀⣰⠃⠀⣳⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⠁⠸⣆⠀⠀⠀⠀⠀⠀⠐⠒⠻⠯⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠾⠿⠭⠭⠴⠦⠤⠤⣤⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⠀⠀⠈⠛⠓⠲⠶⢦⣄⠀⢠⣀⠚⢶⠺⠿⠶⠳⠶⠶⠶⠦⠦⠤⠴⠶⠶⠒⠋⠁⠉⠉⠙⠒⠒⠒⠲⠖⠚⠉⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢷⣈⣿⠛⠶⠷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
" ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⢀⣤⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⡀⠀⠀⣠⣾⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀       ',
" \  '⣠⣴⣦⣼⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⢰⡆⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⢳⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀       ',
" \  '⢻⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⢻⣿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠙⠻⢿⣿⣿⡿⠀⠀⠀⠀⠀⢰⠦⢤⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⠿⠥⠀⠀⠀⠀⠈⣿⣿⣿⣿⣷⣦⣄⣀⣀⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⣸⠀⠀⠈⠛⢿⣿⠿⠋⠁⢀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠰⣼⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠙⠒⠀⢠⣾⣿⠀⠀⠀⠀⠘⠁⠀⠀⢰⣿⣿⣿⣧⠀⠀⠀⠀⣀⡀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠸⣿⡇⠀⠈⠀⠀⣰⣿⣿⣿⣷⣦⠀⠀⠹⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣇⡀⠀⠀⠀⣀⡀⠀⠀⠙⠓⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣇⠀⠀⣿⣿⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⠁⠀⣴⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⠀⠀⣿⣿⣿⣿⡿⠃⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡿⠀⢰⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⡟⠀⢠⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⡇⠀⢸⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠈⠻⠿⠿⠿⠋⠀⢀⣾⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣧⠀⠘⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠊⢹⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣆⠀⠈⠙⠛⠛⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠈⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⡋⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⠓⠲⠤⢤⣀⣀⣀⣀⣀⣠⣤⣶⣿⣿⣇⠀⠀⠀⠀⢸⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠾⠟⠻⠿⣿⠿⡿⢿⣿⣿⡇⠀⢸⣷⡸⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⣿⣶⠀⠋⣠⣠⣾⣿⣿⣿⢀⣾⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣿⣿⠀⠀⠀⢰⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠙⠁⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀       ',
" \  '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀        ',
" \  '',
" \  '⠀⠀          ⠀⣿⣿⡆⠀⠀⢸⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⣾⣿⡆⠀        ',
" \  ' ⠀          ⠀⣿⣿⡇⠀⠀⢸⣿⢰⣿⡆⠀⣾⣿⡆⠀⣾⣷ ⣿⣿⡇⠀⠀⣿⣿⡇⠀        ',
" \  ' ⠀          ⠀⣿⣿⡇⠀⠀⢸⣿⠘⣿⣿⣤⣿⣿⣿⣤⣿⡇⢻⣿⡇⠀⠀⣿⣿⡇⠀         ',
" \  ' ⠀          ⠀⣿⣿⡇⠀⠀⢸⡿⠀⢹⣿⣿⣿⣿⣿⣿⣿⠁⢸⣿⣇⠀⢀⣿⣿⠇⠀         ',
" \  ' ⠀          ⠀⠙⢿⣷⣶⣶⡿⠁⠀⠈⣿⣿⠟⠀⣿⣿⠇⠀⠈⠻⣿⣶⣾⡿⠋⠀⠀         ',

" }}}

if exists("plugs['dashboard-nvim']")
  let g:dashboard_custom_header=[
  \  '',
  \  '',
  \  '',
  \  '',
  \  '',
  \  '',
  \  '',
  \  '',
  \  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣉⡥⠶⢶⣿⣿⣿⣿⣷⣆⠉⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢡⡞⠁⠀⠀⠤⠈⠿⠿⠿⠿⣿⠀⢻⣦⡈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠘⡁⠀⢀⣀⣀⣀⣈⣁⣐⡒⠢⢤⡈⠛⢿⡄⠻⣿⣿⣿⣿⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣶⣄⠉⠐⠄⡈⢀⣿⣿⣿⣿⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⢠⣿⣿⣿⣿⡿⢿⣿⣿⣿⠁⢈⣿⡄⠀⢀⣀⠸⣿⣿⣿⣿⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⣿⣿⣿⡿⠟⣡⣶⣶⣬⣭⣥⣴⠀⣾⣿⣿⣿⣶⣾⣿⣧⠀⣼⣿⣷⣌⡻⢿⣿⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⣿⠟⣋⣴⣾⣿⣿⣿⣿⣿⣿⣿⡇⢿⣿⣿⣿⣿⣿⣿⡿⢸⣿⣿⣿⣿⣷⠄⢻⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⠰⢾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⢂⣭⣿⣿⣿⣿⣿⠇⠘⠛⠛⢉⣉⣠⣴⣾⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⣷⣦⣬⣍⣉⣉⣛⣛⣉⠉⣤⣶⣾⣿⣿⣿⣿⣿⣿⡿⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡘⣿⣿⣿⣿⣿⣿⣿⣿⡇⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
  \  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⢸⣿⣿⣿⣿⣿⣿⣿⠁⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
  \  '',
  \  '',
  \  '',
  \  '',
  \  '',
  \  '',
  \  '',
  \  '',
  \  '',
  \  '',
  \  ]

  " eg : "SPC mean the leaderkey
  let g:dashboard_custom_shortcut= {
  \ 'new_file'           : 'SPC c n',
  \ 'last_session'       : 'SPC s l',
  \ 'find_history'       : 'SPC f h',
  \ 'find_file'          : 'SPC f f',
  \ 'change_colorscheme' : 'SPC t c',
  \ 'find_word'          : 'SPC f a',
  \ 'book_marks'         : 'SPC f b',
  \ }

  let g:dashboard_custom_shortcut_icon={
  \ 'new_file'           : ' ',
  \ 'last_session'       : ' ',
  \ 'find_history'       : 'ﭯ ',
  \ 'find_file'          : ' ',
  \ 'change_colorscheme' : ' ',
  \ 'find_word'          : ' ',
  \ 'book_marks'         : ' ',
  \ }

  function ExtendDashboard()
    hi dashboardFooter    guibg=none guifg=#516d91
    hi dashboardHeader    guibg=none guifg=#e4445a
    hi dashboardCenter    guibg=none guifg=#1f997e
    hi dashboardShortCut  guibg=none guifg=#516d91
  endf

  autocmd FileType dashboard call ExtendDashboard()
end

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" IndentLine Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if exists("plugs['indentLine']")
  let g:indentLine_bufTypeExclude  = ['help', 'man']
  let g:indentLine_fileTypeExclude = ['dashboard']
  let g:indentLine_char_list = ['|', '┆']
end

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" StatusLine Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("*g:SetStatusLineInsertColor") && exists("*g:ResetStatusLineColor")
  autocmd InsertEnter * call g:SetStatusLineInsertColor()
  autocmd InsertLeave * call g:ResetStatusLineColor()
end

function! LinterStatus() abort
  let l:counts = ale#statusline#Count(bufnr(''))

  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  if l:counts.total > 0
    return "[ " . printf(' %d', all_non_errors + all_errors) . " ] "
  else
    return " "
  end
endfunction

function! FileIcon() abort
  let fileicons = [
        \ { "icon": "", "filetypes": ["vim"] },
        \ { "icon": "", "filetypes": ["sh"] },
        \ { "icon": "", "filetypes": ["help"] },
        \ { "icon": "", "filetypes": ["ini", "dosini", "conf", "tmux"] },
        \ { "icon": "", "filetypes": ["gitconfig"] },
        \ { "icon": "", "filetypes": ["ruby"] },
        \ { "icon": "", "filetypes": ["html"] },
        \ { "icon": "", "filetypes": ["slim"] },
        \ { "icon": "", "filetypes": ["css"] },
        \ { "icon": "", "filetypes": ["sass", "scss"] },
        \ { "icon": "", "filetypes": ["javascript"] },
        \ { "icon": "", "filetypes": ["coffee"] },
        \ { "icon": "ﯤ", "filetypes": ["typescript"] },
        \ { "icon": "", "filetypes": ["json", "yaml"] },
        \ { "icon": "縉", "filetypes": ["svg"] },
        \ { "icon": "", "filetypes": ["typescript"] } ]

  for fi in fileicons
    if index(fi["filetypes"], &filetype) != -1
      return fi["icon"] . " "
    end
  endfor

  return ""
endfunction

set statusline=
set statusline+=\  
set statusline+=%=
set statusline+=\  
set statusline+=%f                                          " path
set statusline+=\ \  
set statusline+="
set statusline+=\ \  
set statusline+=%{FileIcon()}                               " lint status
set statusline+=%{&filetype}                               " lint status
set statusline+=\ \  
set statusline+=\ "
set statusline+=\ \  
set statusline+=%{&fileencoding?&fileencoding:&encoding}  " file encoding
set statusline+=\  
if exists("plugs['ale']")
  set statusline+=%{LinterStatus()} " lint status
end
set statusline+=\ \  
set statusline+=%m\ %r                                      " modified\ read-only?
set statusline+=\ \ \                                         " Spacing

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FZF Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("plugs['fzf.vim']")
  let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-s': 'split',
    \ 'ctrl-v': 'vsplit'
    \}

  " Changes fzf highlight
  let g:fzf_colors =
  \ { "fg":      ["fg", "Normal"],
    \ "bg":      ["bg", "Normal"],
    \ "hl":      ["fg", "IncSearch"],
    \ "fg+":     ["fg", "CursorLine", "CursorColumn", "Normal"],
    \ "bg+":     ["bg", "CursorLine", "CursorColumn"],
    \ "hl+":     ["fg", "IncSearch"],
    \ "info":    ["fg", "IncSearch"],
    \ 'border':  ['fg', 'Comment' ],
    \ "prompt":  ["fg", "Comment"],
    \ "pointer": ["fg", "IncSearch"],
    \ "marker":  ["fg", "IncSearch"],
    \ "spinner": ["fg", "IncSearch"],
    \ "header":  ["fg", "WildMenu"] }

  " position window
  let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8, 'yoffset': -5 } }

  " let s:sf_options = ['--preview', 'width': 0.6, 'height': 0.8, 'yoffset': 0 ]
  " command! -bang SinfinFiles call fzf#run({'source': 'find app -name "*.slim" | grep -E "\/cells\/|\/views\/"', 'sink': 'e', 'options': s:f_options})

  " nnoremap <Space>s :FzfSpotlight <C-R><C-W>
end

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CoC Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("plugs['coc.nvim']")
  let g:coc_config_home='~/.config/nvim'
  let g:coc_global_extensions = [
    \ 'coc-snippets',
    \ 'coc-pairs',
    \ 'coc-json', 
    \ 'coc-tsserver', 
    \ 'coc-tslint-plugin', 
    \ 'coc-css', 
    \ 'coc-phpls', 
    \ ]

  " jump between blanks in snippet
  let g:coc_snippet_next = '<tab>'
  let g:coc_snippet_prev = '<LEADER><Tab>'

  " TextEdit might fail if hidden is not set.
  set hidden

  " Some servers have issues with backup files, see #649.
  set nobackup
  set nowritebackup

  " Give more space for displaying messages.
  set cmdheight=3

  " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
  " delays and poor user experience.
  set updatetime=300

  " Don't pass messages to |ins-completion-menu|.
  set shortmess+=c

  " Tab auto-select first completion
  inoremap <silent><expr> <Tab> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<TAB>"
  nnoremap <Leader>snip :<C-u>vsp<CR>:<C-u>CocCommand snippets.editSnippets<CR>
end

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Far Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set lazyredraw            " improve scrolling performance when navigating through large results
set regexpengine=1        " use old regexp engine

let g:far#source='rg'
let g:far#ignore_files=["~/.vim/farignore"]
let g:far#preview_window_height=20
let g:far#limit=200

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ALE Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto-fix
let b:ale_fixers = ['prettier']
let g:ale_fix_on_save = 1

" Lint
let b:ale_linters = ['tsserver']

if exists("plugs['ale']")
  hi clear ALEErrorSign
  hi clear ALEWarningSign
end

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Splits Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set splitbelow
set splitright

nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

noremap <silent> <C-s>+ :resize +3<CR>
noremap <silent> <C-s>- :resize -3<CR>

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colorizer Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("plugs['Colorizer']")
  nnoremap <Leader>ch :ColorToggle<CR>
end

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Git gutter Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("plugs['vim-gitgutter']")
  let g:gitgutter_sign_added = '\ +'
  let g:gitgutter_sign_modified = '\ ~'
  let g:gitgutter_sign_removed = '\ -'
  let g:gitgutter_sign_removed_first_line = '\ -'
  let g:gitgutter_sign_removed_above_and_below = '\ -'
  let g:gitgutter_sign_modified_removed = '\ ~'
end

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text Edit Settings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set nowrap
set expandtab                   " Use spaces instead of tabs.
set smarttab                    " Be smart using tabs ;)
set shiftwidth=2                " One tab == four spaces.
set tabstop=2                   " One tab == four spaces.
" change spacing for language specific

" If inside block put new line
function IsCursorInsideNewBlock()
  let s:chars=getline(".")[col(".")-2:col(".")-1]
  return s:chars =="{}" || s:chars == "><" || s:chars == "[]"
endfunction

inoremap <expr> <CR> IsCursorInsideNewBlock() ? "<CR><esc>O" : "<CR>"

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keybindings: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" map space to leader
nnoremap <Space> <NOP>
let mapleader = " "

" Toggle fold
noremap Z za

" Bring up help
noremap } K

" Join lines
noremap { J

" Advanced movement
noremap H 0
noremap L $

" Block movement
noremap J }
noremap K {

" Clear search
nnoremap <C-c> :nohl<CR>:<CR>

" save, quit
noremap <C-w> :w!<CR>
noremap <C-q> :q<CR>

" yank rest of line
nnoremap Y y$
nnoremap yy Vy

" Better indent
vnoremap > >gv
vnoremap < <gv

" toggle spellcheck
noremap <Leader>ss :setlocal spell!<CR>

" launch vertical help command
nnoremap <Leader>H :vert h 

" surround visual selection with brackets/parenthesis
vnoremap ' c''<ESC>P
vnoremap " c""<ESC>P
vnoremap ` c``<ESC>P

vnoremap ( c()<ESC>P
vnoremap { c{}<ESC>P
vnoremap [ c[]<ESC>P

nnoremap <LEADER>' e<ESC>a'<ESC>bi'<ESC>lel
nnoremap <LEADER>" e<ESC>a"<ESC>bi"<ESC>lel

" tab controls
nnoremap <Tab> gt
nnoremap <S-Tab> gT

nnoremap <LEADER>V :<C-u>source $MYVIMRC<CR>

" open new file in the same directory as the current pane in a vertical split
nnoremap <LEADER>fv :<C-u>vsp %:h/

" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Languages: {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TypeScript: {{{

" Fix typescript redraw exceeded
set re=0

" Set typescript filetype
au BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.typescriptreact

" }}}

" }}}
