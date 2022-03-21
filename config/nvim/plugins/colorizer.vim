" Colorizer Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("plugs['Colorizer']")
  nnoremap <Leader>ch :ColorToggle<CR>

  let g:colorizer_skip_comments = 1

  let g:colorizer_auto_filetype='css,html,vim,yaml,xml,sass,scss,dosini'

  let g:colorizer_disable_bufleave = 1
end
