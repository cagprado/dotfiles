" Vim filetype detection file
" Language: Fortran

" overwrite default detection for .inc files
au BufNewFile,BufRead *.inc  set filetype=fortran
