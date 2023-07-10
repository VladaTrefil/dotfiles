local present, _ = pcall(require, 'wilder')

if not present then
  return
end

vim.cmd([[
  call wilder#setup({
    \ 'modes': [':', '/', '?'],
    \ 'next_key': '<C-p>',
    \ 'previous_key': '<C-n>'
    \ })

  let s:accent = '#e23141'

  let s:scale = ['#f4468f', '#fd4a85', '#ff507a', '#ff566f', '#ff5e63',
        \ '#ff6658', '#ff704e', '#ff7a45', '#ff843d', '#ff9036']

  let s:gradient = map(s:scale, {i, fg -> wilder#make_hl(
      \ 'WilderGradient' . i, 'Pmenu', [{}, {}, {'foreground': fg}]
      \ )})

  call wilder#set_option('renderer', wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
        \ 'highlighter': wilder#highlighter_with_gradient([
        \   wilder#basic_highlighter()
        \ ]),
        \ 'min_width': '30%',
        \ 'max_height': '30%',
        \ 'reverse': '1',
        \ 'highlights': {
        \   'border': 'Blue',
        \   'default': 'Normal',
        \   'accent': wilder#make_hl('WilderAccent', 'Pmenu', [{}, {}, {'foreground': s:accent}]),
        \   'selected': 'Red',
        \   'gradient': s:gradient,
        \ },
        \ 'pumblend': 15,
        \ 'left': [
        \   ' ', wilder#popupmenu_devicons(),
        \ ],
        \ 'right': [
        \   ' ', wilder#popupmenu_scrollbar(),
        \ ],
        \ })))
]])
