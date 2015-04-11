let [s:plugin, s:enter] = maktaba#plugin#Enter(expand('<sfile>:p'))
if !s:enter
  finish
endif

nmap <unique> g<C-A> <Plug>RadicalView
xmap <unique> g<C-A> <Plug>RadicalView

nmap <unique> crd <Plug>RadicalCoerceToDecimal
nmap <unique> crx <Plug>RadicalCoerceToHex
nmap <unique> cro <Plug>RadicalCoerceToOctal
nmap <unique> crb <Plug>RadicalCoerceToBinary
