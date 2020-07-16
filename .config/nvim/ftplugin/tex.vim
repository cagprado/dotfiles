" Vim filetype plugin file
" Language: laTeX

setlocal textwidth=0 showbreak=┊ breakindentopt=min:0,shift:8 cpoptions-=n
let g:vimtex_disable_recursive_main_file_detection=1
let g:vimtex_fold_enabled = 1
let g:vimtex_fold_types = {'envs' : { 'blacklist' : ['center'], }}
let g:tex_conceal = 0
