" Vim filetype plugin file
" Language: laTeX

setlocal foldmarker=<<<,>>>
setlocal textwidth=0 breakindentopt=sbr,min:0,shift:0

"" Add \item inside itemize environment
"function! AddItem()
"  if searchpair('\\begin{itemize}', '', '\\end{itemize}', '') || searchpair('\\begin{enumerate}', '', '\\end{enumerate}', '') || searchpair('\\begin{description}', '', '\\end{description}', '')
"    return "\\item "
"  else
"    return ""
"  endif
"endfunction
"
"" Automatically add \item inside itemize environment when <CR> or o and O
"inoremap <expr><buffer> <CR> getline('.') =~ '\item $' ? '<c-w><c-w>' : '<CR>'.AddItem()
"nnoremap <expr><buffer> o "o".AddItem()
"nnoremap <expr><buffer> O "O".AddItem()
