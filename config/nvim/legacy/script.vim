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
