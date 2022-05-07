" Far Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set lazyredraw            " improve scrolling performance when navigating through large results
set regexpengine=1        " use old regexp engine

let g:far#source='rgnvim'
let g:far#ignore_files=["~/.config/nvim/farignore"]
let g:far#preview_window_height=20
let g:far#limit=200
let g:far#default_file_mask = '*'
