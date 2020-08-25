let s:dir = get(g:, 'vim1cache_dir', expand('~/vim1cache'))

function! vim1cache#AddMemo() abort
  "TODO filename can be configured
  let l:filename = s:dir . "/" . strftime("%Y%m%d_%H%M%S") . ".md"

  "TODO touch command may not be suitable
  exe("edit " . l:filename)
endfunction

function! vim1cache#SearchMemo() abort
  call inputsave()
  let l:keyword = input('Keyword: ')
  call inputrestore()
  exe("vimgrep " . l:keyword . " " . s:dir . "/* | cw")
endfunction
