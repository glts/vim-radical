let [s:plugin, s:enter] = maktaba#plugin#Enter(expand('<sfile>:p'))
if !s:enter
  finish
endif

call maktaba#library#Require('bases')

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
function! s:ShowBases(string, count, ...) abort
  if index([0, 2, 8, 10, 16], a:count) < 0
    call maktaba#error#Shout("Base %s is not supported", a:count)
    return
  endif

  " Determine the query string to use and guess the base
  if a:0
    " Visual mode, use the selection as query string
    let reg_save = @@
    silent execute 'normal! `<' . a:1 . '`>y'
    let l:string = @@
    let @@ = reg_save
  else
    " Normal mode, this relies on <cword> but strip off _ and minus sign
    let l:string = substitute(a:string, '_', '', 'g')
    let l:string = substitute(l:string, '^-', '', '')
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
    let l:number = bases#ParseNumber(l:nrstring, l:base)
  catch /ERROR(\(BadValue\|NumberOverflow\))/
    let l:errormsg = substitute(v:exception, 'ERROR(BadValue): ', '', '')
    return maktaba#error#Shout(l:errormsg)
  endtry
  echomsg printf('<%s>%s  %s,  Hex %s,  Octal %s,  Binary %s',
               \ l:nrstring,
               \ l:base is 10 ? '' : l:base,
               \ l:number,
               \ s:Format(bases#ToHexString(l:number), 4, 0),
               \ s:Format(bases#ToOctalString(l:number), 3, 1),
               \ s:Format(bases#ToBinaryString(l:number), 8, 1),
               \ )
endfunction

nnoremap <unique> <Plug>RadicalView :<C-U>call <SID>ShowBases(expand('<cword>'), v:count)<CR>
xnoremap <unique> <Plug>RadicalView :<C-U>call <SID>ShowBases('', v:count, visualmode())<CR>
