" CoC Settings:
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
