" Regexps and formats for the bases 2, 8, 10, and 16. The 'pattern' of each base
" has one pair of brackets to capture the significant part of the number. The
" key 0 is a special value used for searching for a number of any base.
let s:BASES = {
    \ 0:  {'pattern': '\v\c0x\x+|0o=\o+|0b[01]+|\d+'},
    \ 2:  {'pattern': '\v\c%(0b)=([01]+)',
    \      'format': '0b%s'},
    \ 8:  {'pattern': '\v\c%(0o=)=(\o+)',
    \      'format': '0%s'},
    \ 10: {'pattern': '\v(\d+)',
    \      'format': '%s'},
    \ 16: {'pattern': '\v\c%(0x)=(\x+)',
    \      'format': '0x%s'}
    \ }

function! s:Error(message) abort
  echohl ErrorMsg
  echomsg a:message
  echohl None
endfunction

function! s:CheckIsValidBase(number) abort
  if index([0, 2, 8, 10, 16], a:number) < 0
    call s:Error('Base ' . a:number . ' not supported')
    return 0
  endif
  return 1
endfunction

function! s:NumberStringToInteger(numberstring, base) abort
  let l:pattern = s:BASES[a:base].pattern
  return magnum#Int(substitute(a:numberstring, l:pattern, '\1', ''), a:base)
endfunction

function! s:BasesForBuffer() abort
  if !has_key(b:, 'radical_bases')
    return s:BASES
  endif
  let l:bases = deepcopy(s:BASES)
  for [l:base, l:settings] in items(b:radical_bases)
    call extend(l:bases[l:base], l:settings)
  endfor
  return l:bases
endfunction

function! s:IntegerToString(integer, base, ...) abort
  let l:format = a:0 ? (s:BasesForBuffer()[a:base].format) : '%s'
  return printf(l:format, a:integer.String(a:base))
endfunction

function! s:GuessBase(numberstring) abort
  if a:numberstring =~? '\v^0x\x+$'
    return 16
  elseif a:numberstring =~? '\v^0o=\o+$'
    return 8
  elseif a:numberstring =~? '\v^0b[01]+$'
    return 2
  elseif a:numberstring =~? '\v^\d+$'
    return 10
  endif
  throw 'radical: Cannot guess base of "' . a:numberstring . '"'
endfunction

function! s:ParseNumber(numberstring, base_or_zero) abort
  try
    let l:base = a:base_or_zero is 0 ? s:GuessBase(a:numberstring) : a:base_or_zero
    let l:integer = s:NumberStringToInteger(a:numberstring, l:base)
    return {'integer': l:integer, 'base': l:base}
  catch /\v^(radical|magnum):/
    return {}
  endtry
endfunction

function! s:FindNumberStringWithinLine(base_or_zero, rightwards) abort
  let l:pattern = s:BASES[a:base_or_zero].pattern
  let l:cursor_save = getpos('.')[1:2]
  try
    let l:end = searchpos(l:pattern, 'ce', line('.'))
    if l:end == [0, 0]
      return {}
    endif
    let l:start = searchpos(l:pattern, 'bc', line('.'))
    if !a:rightwards && l:cursor_save[1] < l:start[1]
      return {}
    endif
    let l:string = getline('.')[(l:start[1]-1):(l:end[1]-1)]
    if l:string =~? l:pattern
      return {'numberstring': l:string, 'startcol': l:start[1], 'endcol': l:end[1]}
    endif
    return {}
  finally
    call cursor(l:cursor_save[0], l:cursor_save[1])
  endtry
endfunction

function! s:GetVisualSelection(visualmode) abort
  let l:clipboard_save = &clipboard
  try
    set clipboard=
    let l:reg_save = @@
    silent execute 'normal! `<' . a:visualmode . '`>y'
    let l:string = @@
    let @@ = l:reg_save
    return l:string
  finally
    let &clipboard = l:clipboard_save
  endtry
endfunction

function! s:Format(string, width) abort
  let l:jut = strlen(a:string) % a:width
  let l:padding = l:jut is 0 ? '' : repeat('0', a:width - l:jut)
  return join(split(l:padding . a:string, '\v.{' . a:width . '}\zs'))
endfunction

function! s:PrintBaseInfo(integer, base) abort
  echomsg printf('<%s>%s  %s,  Hex %s,  Octal %s,  Binary %s',
      \ s:IntegerToString(a:integer, a:base),
      \ a:base is 10 ? '' : a:base,
      \ s:IntegerToString(a:integer, 10),
      \ s:Format(s:IntegerToString(a:integer, 16), 4),
      \ s:Format(s:IntegerToString(a:integer, 8), 3),
      \ s:Format(s:IntegerToString(a:integer, 2), 8),
      \ )
endfunction

function! s:ReplaceText(startcol, endcol, replacement) abort
  let l:clipboard_save = &clipboard
  try
    set clipboard=
    let l:reg_save = @@
    let l:expr_reg_save = @=
    call cursor(0, a:startcol)
    normal! v
    call cursor(0, a:endcol)
    execute "normal! c\<C-R>='" . a:replacement . "'\<CR>"
    let @= = l:expr_reg_save
    let @@ = l:reg_save
  finally
    let &clipboard = l:clipboard_save
  endtry
endfunction

" Prints base info for the number under the cursor. When {count} is one of 2, 8,
" 10, 16, then it is the base to use to interpret the number under the cursor;
" when {count} is 0 the base is guessed.
function! radical#NormalView(count) abort
  if !s:CheckIsValidBase(a:count)
    return
  endif
  let l:hit = s:FindNumberStringWithinLine(a:count, 0)
  if empty(l:hit)
    let l:qualifier = a:count is 0 ? '' : (' of base ' . a:count)
    echomsg printf('No number%s under cursor', l:qualifier)
    return
  endif
  let l:number = s:ParseNumber(l:hit.numberstring, a:count)
  call s:PrintBaseInfo(l:number.integer, l:number.base)
endfunction

" Prints base info for the number selected in Visual mode. When {count} is one
" of 2, 8, 10, 16, then it is the base of the selected number; when {count} is 0
" the base is guessed. To be called in Visual mode with a visualmode() argument.
function! radical#VisualView(count, visualmode) abort
  if !s:CheckIsValidBase(a:count)
    return
  endif
  let l:selection = s:GetVisualSelection(a:visualmode)
  let l:number = s:ParseNumber(l:selection, a:count)
  if empty(l:number)
    let l:qualifier = a:count is 0 ? '' : (' of base ' . a:count)
    call s:Error('Invalid number' . l:qualifier . ': "' . l:selection . '"')
    return
  endif
  call s:PrintBaseInfo(l:number.integer, l:number.base)
endfunction

function! s:PlugMapping(base) abort
  let l:name = {10: 'Decimal', 16: 'Hex', 8: 'Octal', 2: 'Binary'}
  return "\<Plug>RadicalCoerceTo" . l:name[a:base]
endfunction

" Searches for a number under or to the right of the cursor and replaces it with
" its base {to_base} representation. When {count} is one of 2, 8, 10, 16, then
" it is the base representation to search for; when {count} is 0 any base will do.
function! radical#CoerceToBase(to_base, count) abort
  if !s:CheckIsValidBase(a:count)
    return
  endif
  let l:hit = s:FindNumberStringWithinLine(a:count, 1)
  if empty(l:hit)
    return
  endif
  let l:number = s:ParseNumber(l:hit.numberstring, a:count)
  let l:string = s:IntegerToString(l:number.integer, a:to_base, 1)
  call s:ReplaceText(l:hit.startcol, l:hit.endcol, l:string)

  silent! call repeat#set(s:PlugMapping(a:to_base), a:count)
endfunction
