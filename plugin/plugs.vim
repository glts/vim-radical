let [s:plugin, s:enter] = maktaba#plugin#Enter(expand('<sfile>:p'))
if !s:enter
  finish
endif

nnoremap <unique> <Plug>RadicalView :<C-U>call radical#RadicalView(expand('<cword>'), v:count)<CR>
xnoremap <unique> <Plug>RadicalView :<C-U>call radical#RadicalView('', v:count, visualmode())<CR>
