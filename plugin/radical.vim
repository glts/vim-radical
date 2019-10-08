if exists('g:loaded_radical') || &compatible
  finish
endif
let g:loaded_radical = 1

nnoremap <silent> <Plug>RadicalView :<C-U>call radical#NormalView(v:count)<CR>
xnoremap <silent> <Plug>RadicalView :<C-U>call radical#VisualView(v:count, visualmode())<CR>
nnoremap <silent> <Plug>RadicalCoerceToDecimal :<C-U>call radical#CoerceToBase(10, v:count)<CR>
nnoremap <silent> <Plug>RadicalCoerceToHex :<C-U>call radical#CoerceToBase(16, v:count)<CR>
nnoremap <silent> <Plug>RadicalCoerceToOctal :<C-U>call radical#CoerceToBase(8, v:count)<CR>
nnoremap <silent> <Plug>RadicalCoerceToBinary :<C-U>call radical#CoerceToBase(2, v:count)<CR>

if !exists('g:radical_no_mappings') || !g:radical_no_mappings
  nmap gA <Plug>RadicalView
  xmap gA <Plug>RadicalView
  nmap crd <Plug>RadicalCoerceToDecimal
  nmap crx <Plug>RadicalCoerceToHex
  nmap cro <Plug>RadicalCoerceToOctal
  nmap crb <Plug>RadicalCoerceToBinary
endif
