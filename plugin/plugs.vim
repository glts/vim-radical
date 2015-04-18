let [s:plugin, s:enter] = maktaba#plugin#Enter(expand('<sfile>:p'))
if !s:enter
  finish
endif

nnoremap <unique> <silent> <Plug>RadicalView
    \ :<C-U>call radical#NormalView(v:count)<CR>
xnoremap <unique> <silent> <Plug>RadicalView
    \ :<C-U>call radical#VisualView(v:count, visualmode())<CR>

nnoremap <unique> <silent> <Plug>RadicalCoerceToDecimal
    \ :<C-U>call radical#CoerceToBase(10, v:count) <Bar>
    \ silent! call repeat#set("\<Plug>RadicalCoerceToDecimal")<CR>
nnoremap <unique> <silent> <Plug>RadicalCoerceToHex
    \ :<C-U>call radical#CoerceToBase(16, v:count) <Bar>
    \ silent! call repeat#set("\<Plug>RadicalCoerceToHex")<CR>
nnoremap <unique> <silent> <Plug>RadicalCoerceToOctal
    \ :<C-U>call radical#CoerceToBase(8, v:count) <Bar>
    \ silent! call repeat#set("\<Plug>RadicalCoerceToOctal")<CR>
nnoremap <unique> <silent> <Plug>RadicalCoerceToBinary
    \ :<C-U>call radical#CoerceToBase(2, v:count) <Bar>
    \ silent! call repeat#set("\<Plug>RadicalCoerceToBinary")<CR>
