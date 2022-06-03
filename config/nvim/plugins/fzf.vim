" FZF Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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

noremap <C-w> :Rg 

" let s:sf_options = ['--preview', 'width': 0.6, 'height': 0.8, 'yoffset': 0 ]
" command! -bang SinfinFiles call fzf#run({'source': 'find app -name "*.slim" | grep -E "\/cells\/|\/views\/"', 'sink': 'e', 'options': s:f_options})

" nnoremap <Space>s :FzfSpotlight <C-R><C-W>
