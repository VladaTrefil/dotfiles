function FolioCell(path)
  let l:dir_name = substitute(getcwd(), '^.*/', '', '')
  let l:cell_name = substitute(a:path, '^.*/', '', '')

  if !filereadable('app/cells/' .. l:dir_name .. '/' .. a:path .. '_cell.rb')
    " let l:cell_path = substitute(a:path, '^.*\=l:dir_name', '')
    execute '!bin/rails g folio:cell ' .. a:path
    execute 'tabnew app/cells/' .. l:dir_name .. '/' .. a:path .. '_cell.rb'
    execute 'vsp app/cells/' .. l:dir_name .. '/' ..a:path .. '/show.slim'
    execute 'vsp app/cells/' .. l:dir_name .. '/' ..a:path .. '/' .. l:cell_name .. '.sass'
  else
    echom 'Cell exists'
  end
endfunction

function RemoveFolioCell(path)
  if filereadable(a:path .. '_cell.rb')
    let l:test_path = substitute(a:path, 'app', 'test', '')
    let l:cell_name = substitute(a:path, '^.*/', '', '')

    execute 'bdelete! ' .. a:path .. '_cell.rb'
    execute 'bdelete! ' .. a:path .. '/show.slim'
    execute 'bdelete! ' .. a:path .. '/' .. l:cell_name .. '.sass'
    execute 'bdelete! ' .. l:test_path .. '_cell_test.rb'

    execute '!rm -rf ' .. a:path
    execute '!rm ' .. a:path .. '_cell.rb'
    execute '!rm ' .. l:test_path .. '_cell_test.rb'
  else
    echom "Cell doesn't exist"
  end
endfunction

command -nargs=+ -complete=file FolioCell call FolioCell(<q-args>)
command -nargs=+ -complete=file RemoveFolioCell call RemoveFolioCell(<q-args>)

" Auto MKdir

if exists("g:loaded_auto_mkdir")
	finish
endif
let g:loaded_auto_mkdir = 1

if !exists("*mkdir")
	echomsg "auto_mkdir: mkdir() is not available, plugin disabled."
	finish
endif

if !has("autocmd")
	echomsg "auto_mkdir: autocommands not available, plugin disabled."
	finish
endif

augroup auto_mkdir
	au!
	au BufWritePre,FileWritePre * call <SID>auto_mkdir()
augroup END

function <SID>auto_mkdir()
	" Get directory the file is supposed to be saved in
	let s:dir = expand("<afile>:p:h")

	" Create that directory (and its parents) if it doesn't exist yet
	if !isdirectory(s:dir)
		call mkdir(s:dir, "p")
	endif
endfunction
