call maktaba#library#Require('magnum.vim')

let s:BASES = {
    \ 0:  {'searchpattern': '0x\x\+\|0o\=\o\+\|0b[01]\+\|\d\+'},
    \ 2:  {'searchpattern': '\%(0b\)\=[01]\+',
    \      'prefixpattern': '^0b',
    \      'format': '0b%s'},
    \ 8:  {'searchpattern': '\%(0o\=\)\=\o\+',
    \      'prefixpattern': '^0o\=',
    \      'format': '0%s'},
    \ 10: {'searchpattern': '\d\+',
    \      'prefixpattern': '^',
    \      'format': '%s'},
    \ 16: {'searchpattern': '\%(0x\)\=\x\+',
    \      'prefixpattern': '^0x',
    \      'format': '0x%s'}
    \ }

function! s:CheckIsValidBase(number) abort
  if !maktaba#value#IsIn(a:number, [0, 2, 8, 10, 16])
    call maktaba#error#Shout('Base %s not supported', a:number)
    return 0
  endif
  return 1
endfunction

function! s:IntegerToString(integer, base, ...) abort
  let l:format = a:0 ? s:BASES[a:base].format : '%s'
  return printf(l:format, a:integer.String(a:base))
endfunction

function! s:NumberStringToInteger(numberstring, base) abort
  let l:rawstring = substitute(a:numberstring, s:BASES[a:base].prefixpattern, '', '')
  return magnum#Int(l:rawstring, a:base)
endfunction

function! s:GuessBase(numberstring) abort
  if a:numberstring =~? '^0x\x\+$'
    return 16
  elseif a:numberstring =~? '^0o\=\o\+$'
    return 8
  elseif a:numberstring =~? '^0b[01]\+$'
    return 2
  elseif a:numberstring =~? '^\d\+$'
    return 10
  endif
  throw maktaba#error#BadValue('Cannot guess base of string "%s"', a:numberstring)
endfunction

function! s:ParseNumber(numberstring, base) abort
  try
    let l:base = a:base is 0 ? s:GuessBase(a:numberstring) : a:base
    let l:integer = s:NumberStringToInteger(a:numberstring, l:base)
    return {'integer': l:integer, 'base': l:base}
  catch /ERROR(BadValue)/
    return {}
  endtry
endfunction

function! s:FindNumberStringWithinLine(base_or_zero, rightwards) abort
  let l:pattern = s:BASES[a:base_or_zero].searchpattern
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
  let l:padded_string = repeat('0', l:jut is 0 ? 0 : (a:width - l:jut)) . a:string
  return join(split(l:padded_string, '.\{' . a:width . '}\zs'))
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
  call cursor(0, a:startcol)
  normal! v
  call cursor(0, a:endcol)
  execute "normal! c\<C-R>='" . a:replacement . "'\<CR>"
endfunction

function! radical#NormalView(count) abort
  if !s:CheckIsValidBase(a:count)
    return
  endif
  let l:hit = s:FindNumberStringWithinLine(a:count, 0)
  if empty(l:hit)
    call maktaba#error#Warn('No number' .
        \ (a:count is 0 ? '' : (' of base ' . a:count)) . ' under cursor')
    return
  endif
  let l:numberinfo = s:ParseNumber(l:hit.numberstring, a:count)
  call s:PrintBaseInfo(l:numberinfo.integer, l:numberinfo.base)
endfunction

function! radical#VisualView(count, visualmode) abort
  if !s:CheckIsValidBase(a:count)
    return
  endif
  let l:selection = s:GetVisualSelection(a:visualmode)
  let l:numberinfo = s:ParseNumber(l:selection, a:count)
  if empty(l:numberinfo)
    let l:message = 'Invalid number' .
        \ (a:count is 0 ? '' : (' of base ' . a:count)) . ': "%s"'
    call maktaba#error#Shout(l:message, l:selection)
    return
  endif
  call s:PrintBaseInfo(l:numberinfo.integer, l:numberinfo.base)
endfunction

function! radical#CoerceToBase(to_base, count) abort
  if !s:CheckIsValidBase(a:count)
    return
  endif
  let l:hit = s:FindNumberStringWithinLine(a:count, 1)
  if empty(l:hit)
    return
  endif
  let l:numberinfo = s:ParseNumber(l:hit.numberstring, a:count)
  let l:string = s:IntegerToString(l:numberinfo.integer, a:to_base, 1)
  call s:ReplaceText(l:hit.startcol, l:hit.endcol, l:string)
endfunction
