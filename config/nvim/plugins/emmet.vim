" Emmet Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd FileType eruby.yaml,yaml,html,css,jsx EmmetInstall

imap   <C-e>  <plug>(emmet-expand-abbr)
imap   <C-e>;   <plug>(emmet-expand-word)
imap   <C-e>u   <plug>(emmet-update-tag)
imap   <C-e>d   <plug>(emmet-balance-tag-inward)
imap   <C-e>D   <plug>(emmet-balance-tag-outward)
imap   <C-e>n   <plug>(emmet-move-next)
imap   <C-e>N   <plug>(emmet-move-prev)
imap   <C-e>i   <plug>(emmet-image-size)
imap   <C-e>/   <plug>(emmet-toggle-comment)
imap   <C-e>j   <plug>(emmet-split-join-tag)
imap   <C-e>k   <plug>(emmet-remove-tag)
imap   <C-e>a   <plug>(emmet-anchorize-url)
imap   <C-e>A   <plug>(emmet-anchorize-summary)
imap   <C-e>m   <plug>(emmet-merge-lines)
imap   <C-e>c   <plug>(emmet-code-pretty)

let g:user_emmet_settings = {
\  'javascript.jsx' : {
\      'extends': 'jsx',
\      'quote_char': "'",
\  },
\}
