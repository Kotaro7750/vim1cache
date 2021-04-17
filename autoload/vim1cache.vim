let s:dir = get(g:, 'vim1cache_dir', expand('~/vim1cache'))
let s:entry_dir = s:dir . '/' . get(g:, 'vim1cache_entry_dir', 'entry')
let s:entry_path_suffix = get(g:, 'vim1cache_entry_path_suffix', 'vim1cache-entry:')
let s:daily_memo = get(g:,'vim1cache_daily_memo', 'Changelog.md')
let s:username = get(g:,'vim1cache_username', 'vim1cache')
let s:email = get(g:,'vim1cache_email', 'vim1cache@example.com')
let s:new_entry_hotkey = get(g:,'vim1cache_new_entry_hotkey', '<Leader>e')
let s:new_entry_function = get(g:,'vim1cache_new_entry_function', 'vim1cache#NewEntry()')
let s:vim1cache_mru_buf = -1

autocmd BufLeave * call vim1cache#SaveMRU()
execute 'autocmd BufEnter ' . s:dir . '/' . s:daily_memo . ' :call vim1cache#WhenNewDay()'
execute 'autocmd BufEnter ' . s:dir . '/' . s:daily_memo . ' nnoremap <buffer> ' . s:new_entry_hotkey . ' :call ' . s:new_entry_function . '<CR>'

function! vim1cache#AddMemo() abort
  "TODO filename can be configured
  let l:filename = s:entry_dir . "/" . strftime("%Y%m%d_%H%M%S") . ".md"

  exe("edit " . l:filename)
endfunction

function! vim1cache#SearchMemo() abort
  call inputsave()
  let l:keyword = input('Keyword: ')
  call inputrestore()
  exe("vimgrep " . l:keyword . " " . s:entry_dir . "/* | cw")
endfunction

function! vim1cache#ListMemo() abort
  let l:qf = []
  let l:files = system('ls ' . s:entry_dir)
  for file in split(l:files,"\n")
    let l:dict = {}
    let l:dict['filename'] = s:entry_dir . '/' . file
    let l:dict['lnum'] = 1
    let l:dict['text'] = system('head -n1 ' . s:entry_dir . '/' . file)

    call add(l:qf,l:dict)
  endfor
  call setqflist(l:qf,'r')
  cwindow
endfunction

function! vim1cache#OpenMemoUnderCursor() abort
  let l:word = expand("<cWORD>")
  let l:matched = matchstr(l:word,s:entry_path_suffix.".*\.md")
  if l:matched ==? ""
    return
  endif

  let l:filename = split(matched,s:entry_path_suffix)[0]
  let l:file_path = s:entry_dir . "/" . l:filename

  if filereadable(l:file_path)
    exe("edit " . l:file_path)
  else
    echo l:file_path . " does not exist"
  endif
endfunction

function! vim1cache#ToggleDailyMemo() abort
  let l:cur_buf = bufnr()
  let l:memo_buf = bufnr(s:dir . "/" . s:daily_memo)

  if l:cur_buf == l:memo_buf
    if bufexists(s:vim1cache_mru_buf) == 1
      execute('buffer ' . s:vim1cache_mru_buf)
    else
      :echo "restorable editor does'nt exist"
    endif
  else
    if l:memo_buf == -1
      execute("e " . s:dir . "/" . s:daily_memo)
      setfiletype changelog
    else
      execute('buffer ' . l:memo_buf)
    endif
  endif
endfunction

function! vim1cache#IsDailyMemoBuf(buf_num) abort
  if a:buf_num == bufnr(s:dir . "/" . s:daily_memo)
    return 1
  else
    return 0
endfunction

function! vim1cache#IsNormalBuf(buf_num) abort
  if buflisted(a:buf_num)
    return 1
  else
    return 0
  endif
endfunction

function! vim1cache#SaveMRU() abort
  let l:leaving_buf = bufnr()
  if !vim1cache#IsDailyMemoBuf(l:leaving_buf) && vim1cache#IsNormalBuf(l:leaving_buf)
    let s:vim1cache_mru_buf = l:leaving_buf
  endif
endfunction

function! vim1cache#InsertNewDay() abort
  let l:date = system('date +\%Y-\%m-\%d')
  let date = date . '  ' . s:username . '  <' . s:email . '>'
  let date = substitute(date,"[[:cntrl:]]","","g")
  :call append(0,l:date)
  :call append(1,"")
endfunction

function! vim1cache#WhenNewDay() abort
  let l:date = system('date +\%Y-\%m-\%d')
  let date = date . '  ' . s:username . '  <' . s:email . '>'
  let date = substitute(date,"[[:cntrl:]]","","g")
  
  let l:line = getline(1)
  if line != date
    :call vim1cache#InsertNewDay()
  endif
endfunction

function! vim1cache#NewEntry() abort
  :call feedkeys("1Go	* ")
endfunction
