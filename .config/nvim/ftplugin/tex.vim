" Vim filetype plugin file
" Language: laTeX

setl tw=0 cc=80

" ft-tex-syntax
let g:tex_conceal = ''
let g:tex_comment_nospell = 1

" vimtex
let g:vimtex_format_enabled = 1
let g:vimtex_syntax_autoload_packages = ['amsmath', 'natbib', 'cleveref', 'asymptote', 'minted']

" vimtex-indent
let g:vimtex_indent_enabled = 1
let g:vimtex_indent_bib_enabled = 1
let g:vimtex_indent_on_ampersands = 0  " breaks manual arrangement of equation parts
let g:vimtex_indent_delims = { 'open': ['{', '['], 'close': ['}', ']'] }

" vimtex-fold
let g:vimtex_fold_enabled = 1
let g:vimtex_fold_types = {
\   'sections' : {
\       'parse_levels' : 0,
\       'sections' : [
\           'section',
\           'subsection',
\           'subsubsection',
\       ],
\   },
\   'envs' : {
\       'blacklist' : [
\           'center',
\       ],
\   },
\}
