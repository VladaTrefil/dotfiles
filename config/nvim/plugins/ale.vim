" ALE Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Auto-fix
let g:ale_linters = {
    \   'ruby': ['standardrb', 'rubocop'],
    \}

let g:ale_fixers = {
      \    'ruby': ['rubocop'],
      \}

let g:ale_fix_on_save = 1

" hi clear ALEErrorSign
" hi clear ALEWarningSign
