"
"                    __                
"      ___   __  __ /\_\    ___ ___    
"    /' _ `\/\ \/\ \\/\ \ /' __` __`\  
"    /\ \/\ \ \ \_/ |\ \ \/\ \/\ \/\ \ 
"    \ \_\ \_\ \___/  \ \_\ \_\ \_\ \_\
"     \/_/\/_/\/__/    \/_/\/_/\/_/\/_/
"                                      

" ASCII: https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=Larry%203D

" Plugins
source ~/.config/nvim/plugins.vim

" LSP
source ~/.config/nvim/lua/lsp/setup.lua

" ────────────────────────────────────────────────────────────────────────────────────────────────────
" General: {{{

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

" Enable mouse control for resizing panes
set mouse=a

"Disable safe write for webpack compilation
set backupcopy=yes

" Offset from end of window to start scrolling
set scrolloff=10

" Enable setting vim options in files
set modeline

" Automaticaly reload changed files
set autoread

" source vimrc when saving any vim file
autocmd! BufWritePost .vimrc source $MYVIMRC

autocmd BufWinLeave .vimrc mkview
autocmd BufWinEnter .vimrc silent loadview 

if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8
endif

if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j " Delete comment character when joining commented lines
endif

" Disable perl provider
let g:loaded_perl_provider = 0

" }}}
" ────────────────────────────────────────────────────────────────────────────────────────────────────

" ────────────────────────────────────────────────────────────────────────────────────────────────────
" Tabline: {{{

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
" ────────────────────────────────────────────────────────────────────────────────────────────────────

" ────────────────────────────────────────────────────────────────────────────────────────────────────
" Splits: {{{

set splitbelow
set splitright

nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

noremap <silent> <C-s>+ :resize +3<CR>
noremap <silent> <C-s>- :resize -3<CR>

" }}}
" ────────────────────────────────────────────────────────────────────────────────────────────────────

" ────────────────────────────────────────────────────────────────────────────────────────────────────
" Text Edit Settings: {{{

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
" ────────────────────────────────────────────────────────────────────────────────────────────────────

" ────────────────────────────────────────────────────────────────────────────────────────────────────
" Keybindings: {{{

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

" save, quit
noremap <C-p> :w!<CR>
noremap <C-q> :q<CR>

noremap <BS> <C-o>

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

" Use <C-c> to clear the highlighting of :set hlsearch.
nnoremap <silent> <C-c> :nohlsearch<C-R><CR><CR><C-c>

" }}}
" ────────────────────────────────────────────────────────────────────────────────────────────────────

" ────────────────────────────────────────────────────────────────────────────────────────────────────
" Languages: {{{

" TypeScript: {{{

" Fix typescript redraw exceeded
set re=0

" Set typescript filetype
au BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.typescriptreact

" }}}

" }}}
" ────────────────────────────────────────────────────────────────────────────────────────────────────

" ────────────────────────────────────────────────────────────────────────────────────────────────────
" Folds: {{{

" Folds
function FoldText()
  let l:line = getline(v:foldstart)
  let l:pattern='\#\|"\|-\+\|{\+'

  let l:text = substitute(l:line, l:pattern, '', 'g')

  let l:fold_size = v:foldend - v:foldstart
  let l:spacer_size = 96 - len(l:text) - len(l:fold_size)

  return ' ' . l:text . repeat('.', l:spacer_size)  . " (" . l:fold_size . " L)  "
endfunction

set foldmethod=marker
set foldtext=FoldText()
set fillchars=fold:\ 
set foldenable

autocmd BufWinEnter *.snippets silent set foldmethod=marker
autocmd BufWinEnter *.snippets silent set foldlevel=0

" }}}
" ────────────────────────────────────────────────────────────────────────────────────────────────────

" ────────────────────────────────────────────────────────────────────────────────────────────────────
" Folio: {{{

function FolioCell(path)
  let l:dir_name = substitute(getcwd(), '^.*/', '', '')
  let l:cell_name = substitute(a:path, '^.*/', '', '')

  if !filereadable('app/cells/' .. l:dir_name .. '/' .. a:path .. '_cell.rb')
    " let l:cell_path = substitute(a:path, '^.*\=l:dir_name', '')
    execute '!bin/rails g folio:cell ' .. a:path
    execute 'tabnew app/cells/' .. l:dir_name .. '/' .. a:path .. '_cell.rb'
    execute 'vsp app/cells/' .. l:dir_name .. '/' ..a:path .. '/show.slim'
    execute 'vsp app/cells/' .. l:dir_name .. '/' ..a:path .. '/' .. l:cell_name .. '.sass'
  else
    echom 'Cell exists'
  end
endfunction

function RemoveFolioCell(path)
  if filereadable(a:path .. '_cell.rb')
    let l:test_path = substitute(a:path, 'app', 'test', '')
    let l:cell_name = substitute(a:path, '^.*/', '', '')

    execute 'bdelete! ' .. a:path .. '_cell.rb'
    execute 'bdelete! ' .. a:path .. '/show.slim'
    execute 'bdelete! ' .. a:path .. '/' .. l:cell_name .. '.sass'
    execute 'bdelete! ' .. l:test_path .. '_cell_test.rb'

    execute '!rm -rf ' .. a:path
    execute '!rm ' .. a:path .. '_cell.rb'
    execute '!rm ' .. l:test_path .. '_cell_test.rb'
  else
    echom "Cell doesn't exist"
  end
endfunction

command -nargs=+ -complete=file FolioCell call FolioCell(<q-args>)
command -nargs=+ -complete=file RemoveFolioCell call RemoveFolioCell(<q-args>)

" }}}
" ────────────────────────────────────────────────────────────────────────────────────────────────────
