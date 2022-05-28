" Dashboard Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:dashboard_custom_header=[
\  '',
\  '',
\  '',
\  '',
\  '',
\  '',
\  '',
\  '',
\  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣉⡥⠶⢶⣿⣿⣿⣿⣷⣆⠉⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢡⡞⠁⠀⠀⠤⠈⠿⠿⠿⠿⣿⠀⢻⣦⡈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠘⡁⠀⢀⣀⣀⣀⣈⣁⣐⡒⠢⢤⡈⠛⢿⡄⠻⣿⣿⣿⣿⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣶⣄⠉⠐⠄⡈⢀⣿⣿⣿⣿⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⢠⣿⣿⣿⣿⡿⢿⣿⣿⣿⠁⢈⣿⡄⠀⢀⣀⠸⣿⣿⣿⣿⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⣿⣿⣿⡿⠟⣡⣶⣶⣬⣭⣥⣴⠀⣾⣿⣿⣿⣶⣾⣿⣧⠀⣼⣿⣷⣌⡻⢿⣿⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⣿⠟⣋⣴⣾⣿⣿⣿⣿⣿⣿⣿⡇⢿⣿⣿⣿⣿⣿⣿⡿⢸⣿⣿⣿⣿⣷⠄⢻⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⠰⢾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⢂⣭⣿⣿⣿⣿⣿⠇⠘⠛⠛⢉⣉⣠⣴⣾⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⣷⣦⣬⣍⣉⣉⣛⣛⣉⠉⣤⣶⣾⣿⣿⣿⣿⣿⣿⡿⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡘⣿⣿⣿⣿⣿⣿⣿⣿⡇⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
\  '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⢸⣿⣿⣿⣿⣿⣿⣿⠁⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
\  '',
\  '',
\  '',
\  '',
\  '',
\  '',
\  '',
\  '',
\  '',
\  '',
\  ]

" eg : "SPC mean the leaderkey
let g:dashboard_custom_shortcut= {
\ 'new_file'           : 'SPC c n',
\ 'last_session'       : 'SPC s l',
\ 'find_history'       : 'SPC f h',
\ 'find_file'          : 'SPC f f',
\ 'change_colorscheme' : 'SPC t c',
\ 'find_word'          : 'SPC f a',
\ 'book_marks'         : 'SPC f b',
\ }

let g:dashboard_custom_shortcut_icon={
\ 'new_file'           : ' ',
\ 'last_session'       : ' ',
\ 'find_history'       : 'ﭯ ',
\ 'find_file'          : ' ',
\ 'change_colorscheme' : ' ',
\ 'find_word'          : ' ',
\ 'book_marks'         : ' ',
\ }

function! ExtendDashboard()
  hi dashboardFooter    guibg=none guifg=#516d91
  hi dashboardHeader    guibg=none guifg=#e4445a
  hi dashboardCenter    guibg=none guifg=#1f997e
  hi dashboardShortCut  guibg=none guifg=#516d91
endf

autocmd FileType dashboard call ExtendDashboard()
