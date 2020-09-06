let s:dir = get(g:, 'vim1cache_dir', expand('~/vim1cache'))

function! vim1cache#AddMemo() abort
  "TODO filename can be configured
  let l:filename = s:dir . "/" . strftime("%Y%m%d_%H%M%S") . ".md"

  exe("edit " . l:filename)
endfunction

function! vim1cache#SearchMemo() abort
  call inputsave()
  let l:keyword = input('Keyword: ')
  call inputrestore()
  exe("vimgrep " . l:keyword . " " . s:dir . "/* | cw")
endfunction

function! vim1cache#ListMemo() abort
  let l:qf = []
  let l:files = system('ls ' . s:dir)
  for file in split(l:files,"\n")
    let l:dict = {}
    let l:dict['filename'] = s:dir . '/' . file
    let l:dict['lnum'] = 1
    let l:dict['text'] = system('head -n1 ' . s:dir . '/' . file)

    call add(l:qf,l:dict)
  endfor
  call setqflist(l:qf,'r')
  cwindow
endfunction
