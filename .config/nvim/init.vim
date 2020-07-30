" INITIALIZATION ############################################################
" clear autocmd and set nocompatible (not vi compatible)
autocmd!
set nocompatible   " required for bundles
let mapleader=','  " set mapleader for custom maps

" add VIM runtime
if has('nvim') | set rtp^=/usr/share/vim/vimfiles | endif

" Dein plugin manager
set runtimepath+=~/.vim/bundles/repos/github.com/Shougo/dein.vim
if dein#load_state('~/.vim/bundles')
    call dein#begin('~/.vim/bundles')
    call dein#add('~/.vim/bundles/repos/github.com/Shougo/dein.vim')

    " interface
    call dein#add('vim-airline/vim-airline')      " airline status line
    call dein#add('Shougo/deoplete.nvim')         " completion
    call dein#add('lilydjwg/fcitx.vim')           " fcitx input method
    call dein#add('tpope/vim-fugitive')           " git interaction
    call dein#add('luochen1990/rainbow')          " rainbow color parenthesis
    call dein#add('tpope/vim-surround')           " surrounding moves
    call dein#add('Shougo/neosnippet.vim')        " snippets engine
    call dein#add('Shougo/neosnippet-snippets')   " snippets library

    " syntax
    call dein#add('chikamichi/mediawiki.vim')     " mediawiki
    call dein#add('vim-pandoc/vim-pandoc-syntax') " pandoc/markdown
    call dein#add('peterhoeg/vim-qml')            " qt-qml

    " ide-like
    call dein#add('lervag/vimtex')                " LaTeX plugin
    call dein#add('python-mode/python-mode')      " Python syntax plugin

    call dein#end()
    call dein#save_state()
endif
filetype plugin indent on " indent is optional

" auto install plugins on startup
if dein#check_install()
    call dein#install()
endif

" auto remove unused plugins on startup
"call map(dein#check_clean(), "delete(v:val, 'rf')")

" BASIC INTERFACE ###########################################################
" options depending on other sections of .vimrc are commented with <USER SEC>

" misc
set title              " automatically set window title <USER TERM>
set hidden             " hide buffer if opening new one (no need to save/undo)
set ttyfast            " fast terminal connection: smooths things
set modelineexpr       " allow modeline expressions
set wildignore=*.swp,*.bak,*.pyc,*.class,*.zwc  " ignore when completing
set wildmode=list:longest,full  " complete command-line (list options and complete common part then cycle)
set nospell            " turn off spell checking
set spelllang=en_us    " set default spell language
set complete+=kspell   " current spell for keyword completion (C-P C-N)
set timeoutlen=3000    " timeout for key mapping
set ttimeoutlen=10     " timeout for key codes
set relativenumber     " show relative line numbers
set cursorline         " highlight cursor position line
set showmatch          " highlight matching ( )
set laststatus=2       " always show status line
set showcmd            " show partially-typed commands in status line
set showmode           " show mode (Insert, Replace, Visual) in status line
set foldmethod=marker  " set the folding method TODO
set fillchars=fold:─   " set character to fill lines to window width
set makeprg=           " set makeprg empty (to be filled later by FileType)

" printing (set html options for :TOhtml)
let g:html_number_lines=1
let g:html_pre_wrap=1
let g:html_ignore_conceal=1
let g:html_ignore_folding=1
let g:html_font="terminalfont"

" indenting
set tabstop=4             " \t length
set shiftwidth=4          " indenting steps (=0: tabstop)
set softtabstop=4         " <TAB> inserts N spaces|\t if possible (=neg: shiftwidth)
set expandtab             " <TAB> never inserts \t (C-V<TAB> will do)
set shiftround            " round > and < to multiples of shiftwidth
set autoindent            " copies indent of previous line
set copyindent            " use same structure instead of tab characters

" searching and substituting <USER KEYMAP>
set ignorecase       " ignore case when searching
set smartcase        " only ignore case if all lowercase
set hlsearch         " highlight search terms <USER MAP>
set incsearch        " search as you type
set gdefault         " assume g flag on :s (put explicit g to disable flag)

" history and backup
set history=1000              " remember X commands and search history
set undolevels=1000           " save X undo levels
set directory=~/var/backup    " swapfile location
set swapfile                  " turn on swapfile
set backupdir=~/var/backup    " backup file location
set backup                    " turn on backup
set undodir=~/var/backup      " undofile location
set undofile                  " turn on undo file
set viminfo=%,h,'50           " saves up to 50 buffers, buf-list and disable hlsearch

" editing behaviour:
if !&diff | set scrolloff=5 | endif  " minimum context around cursor
set textwidth=77                     " text width length
set colorcolumn=+1                   " highlight 1 column after textwidth
set joinspaces                       " when joining insert two spaces after .?!
set cpoptions+=J                     " a sentence will end with two spaces
set backspace=indent,eol,start       " backspace over everything
set virtualedit=all                  " allow cursor to travel anywhere
set clipboard^=unnamedplus           " copy/paste to "+ without explicit set
set wrap                             " soft wrap lines
set linebreak                        " breaks with breakat instead of last char
set showbreak=│\                      " showbreak when soft-wrapping
set breakindent                      " follow indent when soft-wrapping
set breakindentopt=shift:0           " sbr: showbreak before indent / min: 0=any / shift: number of chars to shift
set list                             " turn on list mode: listchars sets contexts
set listchars=tab:.…,trail:·,extends:»,precedes:«,nbsp:~
set formatoptions=tcroqjn            " options for formating, :help fo-table, match number, -, · lists
set formatlistpat=^\\s*\\(\\d\\+[\\]:.)}\\t\ ]\\\\|-\\\\|·\\)\\s*


" Set cursor shape for different modes (tmux will do it right)
if has('nvim') && $TERM !~ '\vlinux'
    set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,
                 \i-ci:ver25-Cursor/lCursor-blinkon0,
                 \r-cr:hor20-Cursor/lCursor-blinkon0
else
    let &t_SI = system('tput Ss 6 2>/dev/null')
    let &t_EI = system('tput Ss 2 2>/dev/null')
    if exists('&t_SR')
        let &t_SR = system('tput Ss 4 2>/dev/null')
    endif
    autocmd VimEnter * silent exe '!echo -ne ' . shellescape(&t_EI)
    autocmd VimLeave * silent exe '!tput Se 2>/dev/null'
endif

" Syntax highlighting and appearance
if has('syntax')
    let s:has_truecolor = system('tput Tc 2>/dev/null && echo 1 || echo 0')
    if (has('termguicolors') && s:has_truecolor) || has('gui_running')
        " Set truecolor option and load colorscheme
        set termguicolors
        let g:rainbow_active=1
    endif

    syntax on
    colorscheme default
endif

" AIRLINE ###################################################################
let g:airline_skip_empty_sections = 1
let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]'

if !exists('g:airline_symbols') | let g:airline_symbols = {} | endif
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.branch = ''
let g:airline_symbols.maxlinenr = ''

if $TERM !~ '\vlinux'
    " special characters for GUI terminal (with special font)
    let g:airline_symbols.linenr = ' '
    let g:airline_symbols.crypt = ' '
    let g:airline_symbols.whitespace = ' '
    let g:airline_symbols.dirty='  '
    let g:airline_symbols.paste = ' '
    let g:airline_symbols.spell = ' '
endif

" redefine line number section
if &termguicolors
    call airline#parts#define('linenr', {'raw': ' %l', 'accent': 'bold' })
else
    call airline#parts#define_accent('linenr', 'none')
endif

call airline#parts#define('maxlinenr', {
        \ 'raw' : ':%v %{g:airline_symbols.maxlinenr} %L',
        \ 'accent' : 'none'})

let g:airline_section_z = airline#section#create([ 'windowswap', 'obsession',
        \ '%p%% %{g:airline_symbols.linenr}', 'linenr', 'maxlinenr' ])

" COMPLETION ################################################################
let g:deoplete#enable_at_startup = 1
set completeopt+=noinsert
autocmd CompleteDone * silent! pclose!

" PYTHON-MODE ###############################################################
let g:pymode_python = 'python3'

" FUNCTIONS/AUTOCMD #########################################################

" Convert current buffer to pdf
function! ToPdf()
    write

    " Generate HTML file
    let l:filename=expand('%:S')
    let l:htmlname=expand('%') . '.html'
    TOhtml
    let &l:makeprg = "wkhtmltopdf --disable-smart-shrinking -s A4 --header-left " . l:filename . " --header-right '[page]/[toPage]' --header-line --header-spacing 2 -T 18 -B 12 -L 18 -R 18 %:S %:r:S.pdf"
    write | make!

    " Delete temporary HTML file
    call delete(expand('%')) | bdelete!
endfunction
command! -bar ToPdf call ToPdf()

" Restore cursor position to last position when load buffer
function! RestoreCursor()
    if line("'\"") <= line("$")
        normal! g`"
        return 1
    endif
endfunction
au BufWinEnter * call RestoreCursor()

" Cycle through spelllang list (rather than setting multiple at same time)
let g:SpellLangList = ["","en_us","pt_br"]
function! CycleSpellLang()
  let b:CurrentLang = g:SpellLangList[(index(g:SpellLangList, &spelllang)+1) % len(g:SpellLangList)]
  if b:CurrentLang == ""
    exe "setlocal nospell spelllang="
    echo "spell checking off"
  else
    exe "setlocal spell spelllang=" . b:CurrentLang
    echo "spell checking language:" . b:CurrentLang
  endif
endfunction

" KEY MAPPING ###############################################################

" Paragraph formatting
vmap Q gq
nmap Q gqap

" Clear trailing spaces
nnoremap <leader>cs :%s/\s\+$//<CR>:let @/=''<CR>

" Clear search highlight with ,/
nmap <silent> <leader>/ :nohlsearch<CR>

" Use \v for all search (makes pattern closer to other languages)
nnoremap / /\v
vnoremap / /\v

" Show all used highlighting groups
map <silent> <F10> :runtime syntax/hitest.vim<CR>

" runtime syntax/hitest.vim
" toggle pastemode
set pastetoggle=<F2>

" select text just pasted (will work if issued right after pasting)
nnoremap <leader>v V`]

" mapping to make movements operate on 1 screen line in wrap mode
function! ScreenMovement(movement)
   if &wrap
      return "g" . a:movement
   else
      return a:movement
   endif
endfunction
noremap <silent> <expr> j ScreenMovement("j")
noremap <silent> <expr> k ScreenMovement("k")
noremap <silent> <expr> 0 ScreenMovement("0")
noremap <silent> <expr> ^ ScreenMovement("^")
noremap <silent> <expr> $ ScreenMovement("$")

" Change windows easily: <C-X> instead of <C-w>X
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" If forgot sudo use w!! to sudo when saving file
cmap w!! w !sudo tee % >/dev/null

" cycle through SpellLangList
map <silent> <F12> :call CycleSpellLang()<CR>
imap <silent> <F12> <C-o>:call CycleSpellLang()<CR>

" set spell checking on for some file types
au BufNewFile,BufRead *.{txt,mail,tex} setlocal spell
au FileType help setlocal nospell

" compile
function! SetMakePrg()
  let filedir = expand('%:p:h')

  let l:is_executable = system("test -x " . expand("%:S") . " && echo 1 || echo 0")
  if l:is_executable
    let &makeprg = "./%:S"                     " Executable: exec itself
  elseif filereadable("Makefile")
    let &makeprg = "make"                      " Make in the current dir
  elseif filereadable(filedir . "/Makefile")
    let &makeprg = "make -C " . filedir        " Make in the same dir as file
  " -- File Specific compile/run commands -----------------------------------
  elseif expand("%") =~ '\.sh$\|\.zsh$'
    let &makeprg = "zsh %:S"
  elseif expand("%") =~ '\.asy$'
    let &makeprg = "asy -nosafe %:S"
  elseif expand("%") =~ '\.py$'
    let &makeprg = "python %:S"
  elseif expand("%") =~ '\.md$'
    let &makeprg = "pandoc -s -f markdown+smart %:S -o %:r:S.pdf"
  elseif expand("%") =~ '\.wiki$'
    let &makeprg = "pandoc -s -f mediawiki+smart %:S -o %:r:S.pdf"
  else
    let &makeprg = 'echo "No makeprg configured for this file..."'
  endif
endfunction
au BufNewFile,BufRead * call SetMakePrg()
map <silent> <F11> :w <bar> :make!<CR>
imap <silent> <F11> <C-o>:w <bar> :make!<CR>

" snippets
map <leader>esn :UltiSnipsEdit<CR>
