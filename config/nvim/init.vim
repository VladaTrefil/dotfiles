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
" Cancel highlight on source vimrc
nohlsearch
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

" Enable setting vim options in files (vim: set ft='sh')
set modeline

" Enable current line hightlight
set cursorline

" Automaticaly reload changed files
set autoread

au FocusGained,BufEnter * :checktime

" source vimrc when saving any file in nvim config directory
autocmd! BufWritePost $HOME/config/nvim/* source $MYVIMRC

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
" Splits: {{{

set splitbelow
set splitright

nmap <silent> <C-k> :wincmd k<CR>
nmap <silent> <C-j> :wincmd j<CR>
nmap <silent> <C-h> :wincmd h<CR>
nmap <silent> <C-l> :wincmd l<CR>

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

nnoremap <silent> <Leader>Q <ESC>:qa!<CR>

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
noremap K {
noremap J }

" yank rest of line
nnoremap Y y$
nnoremap yy Vy

" Save/Load session
nnoremap <silent> <Leader>ss <CR>:SessionSave<Tab><CR>
nnoremap <silent> <Leader>sl <CR>:SessionLoad<Tab><CR>

" Open current fold in vertical window
nnoremap <silent> <Leader>ov <CR>:vsp %:h<Tab><CR>
" Open current fold in horizontal window
nnoremap <silent> <Leader>oh <CR>:sp %:h<Tab><CR>

nnoremap <silent> <Leader>p :Files<CR>
nnoremap <silent> <Leader><Leader>p :GFiles<CR>

nnoremap <Leader><Leader>h :vert h 

" save
noremap <Leader>w :w!<CR>

" clear the highlighting of :set hlsearch.
nnoremap <silent> <Leader>c :nohlsearch<C-R><CR><CR><C-c>

nnoremap <Leader>V :<C-u>source $MYVIMRC<CR>

" open new file in the same directory as the current pane in a vertical split
nnoremap <Leader>fv :<C-u>vsp %:h/

" toggle spellcheck
noremap <Leader>sc :setlocal spell!<CR>

" Surround with parenthesis
nnoremap <Leader>' e<ESC>a'<ESC>bi'<ESC>lel
nnoremap <Leader>" e<ESC>a"<ESC>bi"<ESC>lel

nnoremap <Leader>b <ESC>:BlamerToggle<CR><C-c>

" Backspace goes back
noremap <BS> <C-o>

" Better indent
vnoremap > >gv
vnoremap < <gv

" Visual:
" surround visual selection with brackets/parenthesis
vnoremap ' c''<ESC>P
vnoremap " c""<ESC>P
vnoremap ` c``<ESC>P

vnoremap ( c()<ESC>P
vnoremap { c{}<ESC>P
vnoremap [ c[]<ESC>P

" Tabs:
nnoremap <Leader>tj gt
nnoremap <Leader>tk gT
nnoremap <Leader>tc <ESC>:tabclose<CR>

" Close buffer and window
nnoremap <silent> <Leader>q <ESC>:bd<CR>
nnoremap <silent> <Leader>bj <ESC>:bnext<CR>
nnoremap <silent> <Leader>bk <ESC>:bprevious<CR>

" }}}
" ────────────────────────────────────────────────────────────────────────────────────────────────────

" ────────────────────────────────────────────────────────────────────────────────────────────────────
" Languages: {{{

" TypeScript:

" Fix typescript redraw exceeded
set re=0

" Set typescript filetype
au BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.typescriptreact

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
