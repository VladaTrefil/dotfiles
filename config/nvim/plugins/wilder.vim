" Wilder Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("plugs['wilder.nvim']")
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
end
