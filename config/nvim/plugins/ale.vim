" ALE Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto-fix
let b:ale_fixers = ['prettier']
let g:ale_fix_on_save = 1

" Lint
let b:ale_linters = ['tsserver']

hi clear ALEErrorSign
hi clear ALEWarningSign
