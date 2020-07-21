" Vim filetype detection file
" Language: tex/latex file

let g:tex_flavor = 'latex'
au BufRead,BufNewFile *.pre  set filetype=tex
