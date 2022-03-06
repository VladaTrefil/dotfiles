" StatusLine Settings:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("*g:SetStatusLineInsertColor") && exists("*g:ResetStatusLineColor")
  autocmd InsertEnter * call g:SetStatusLineInsertColor()
  autocmd InsertLeave * call g:ResetStatusLineColor()
end

function! LinterStatus() abort
  let l:counts = ale#statusline#Count(bufnr(''))

  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  if l:counts.total > 0
    return "[ " . printf(' %d', all_non_errors + all_errors) . " ] "
  else
    return " "
  end
endfunction

function! FileIcon() abort
  let fileicons = [
        \ { "icon": "", "filetypes": ["vim"] },
        \ { "icon": "", "filetypes": ["sh"] },
        \ { "icon": "", "filetypes": ["help"] },
        \ { "icon": "", "filetypes": ["ini", "dosini", "conf", "tmux"] },
        \ { "icon": "", "filetypes": ["gitconfig"] },
        \ { "icon": "", "filetypes": ["ruby"] },
        \ { "icon": "", "filetypes": ["html"] },
        \ { "icon": "", "filetypes": ["slim"] },
        \ { "icon": "", "filetypes": ["css"] },
        \ { "icon": "", "filetypes": ["sass", "scss"] },
        \ { "icon": "", "filetypes": ["javascript"] },
        \ { "icon": "", "filetypes": ["coffee"] },
        \ { "icon": "ﯤ", "filetypes": ["typescript"] },
        \ { "icon": "", "filetypes": ["json", "yaml"] },
        \ { "icon": "縉", "filetypes": ["svg"] },
        \ { "icon": "", "filetypes": ["typescript"] } ]

  for fi in fileicons
    if index(fi["filetypes"], &filetype) != -1
      return fi["icon"] . " "
    end
  endfor

  return ""
endfunction

set statusline=
set statusline+=\  
set statusline+=%=
set statusline+=\  
set statusline+=%f                                          " path
set statusline+=\ \  
set statusline+="
set statusline+=\ \  
set statusline+=%{FileIcon()}                               " lint status
set statusline+=%{&filetype}                               " lint status
set statusline+=\ \  
set statusline+=\ "
set statusline+=\ \  
set statusline+=%{&fileencoding?&fileencoding:&encoding}  " file encoding
set statusline+=\  
if exists("plugs['ale']")
  set statusline+=%{LinterStatus()} " lint status
end
set statusline+=\ \  
set statusline+=%m\ %r                                      " modified\ read-only?
set statusline+=\ \ \                                         " Spacing
