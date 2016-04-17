let [s:plugin, s:enter] = maktaba#plugin#Enter(expand('<sfile>:p'))
if !s:enter
  finish
endif

nmap <unique> gA <Plug>RadicalView
xmap <unique> gA <Plug>RadicalView

nmap <unique> crd <Plug>RadicalCoerceToDecimal
nmap <unique> crx <Plug>RadicalCoerceToHex
nmap <unique> cro <Plug>RadicalCoerceToOctal
nmap <unique> crb <Plug>RadicalCoerceToBinary
