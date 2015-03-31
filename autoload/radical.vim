call maktaba#library#Require('magnum.vim')

" Returns {string} zero-padded and partitioned into groups of width {width}.
" When {always} is true, the zero-padding is always added, even for strings
" shorter than {width}. When it is false, no padding is added in that case.
function! s:Format(string, width, always) abort
  let l:len = len(a:string)
  if a:always || l:len > a:width
    let l:string = repeat('0', l:len%a:width is 0 ? 0 : a:width-l:len%a:width) . a:string
    return join(split(l:string, '.\{' . a:width . '}\zs'), ' ')
  else
    return a:string
  endif
endfunction

" Shows the bases for a number {string} of base {count} (default 10). When the
" optional argument is present it should be one of the Visual mode characters.
function! s:ShowBases(string, count, visualmode) abort
  if index([0, 2, 8, 10, 16], a:count) < 0
    call maktaba#error#Shout("Base %s is not supported", a:count)
    return
  endif

  " Determine the query string to use and guess the base
  if a:visualmode is ''
    " Normal mode, this relies on <cword> but strip off _ and minus sign
    let l:string = substitute(a:string, '_', '', 'g')
    let l:string = substitute(l:string, '^-', '', '')
  else
    " Visual mode, use the selection as query string
    let reg_save = @@
    silent execute 'normal! `<' . a:visualmode . '`>y'
    let l:string = @@
    let @@ = reg_save
  endif
  if a:count isnot 0
    let l:base = a:count
  elseif l:string =~? '^0x\x\+$'
    let l:base = 16
  elseif l:string =~? '^0o\=\o\+$'
    let l:base = 8
  elseif l:string =~? '^0\=b[01]\+$'
    let l:base = 2
  elseif l:string =~? '^\d\+$'
    let l:base = 10
  else
    call maktaba#error#Shout("Not a valid number: %s", l:string)
    return
  endif

  " Extract the actual query string: \x contains \d contains \o contains [01],
  " so the following pattern is good enough.
  let l:nrstring = matchstr(l:string, '\x\+$')
  try
    let l:int = magnum#Int(l:nrstring, l:base)
  catch /ERROR(BadValue)/
    return maktaba#error#Shout(maktaba#error#Split(v:exception)[1])
  endtry
  echomsg printf('<%s>%s  %s,  Hex %s,  Octal %s,  Binary %s',
               \ l:nrstring,
               \ l:base is 10 ? '' : l:base,
               \ l:int.String(),
               \ s:Format(l:int.String(16), 4, 0),
               \ s:Format(l:int.String(8), 3, 1),
               \ s:Format(l:int.String(2), 8, 1),
               \ )
endfunction

function! radical#RadicalView(string, count, ...) abort
  call s:ShowBases(a:string, a:count, a:0 ? a:1 : '')
endfunction
