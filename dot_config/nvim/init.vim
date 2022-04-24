autocmd!
augroup UserGroup
" • settings                                                             {{{1
"  - history and backup                                                  {{{2
set backup                      " turn on backup
set swapfile                    " turn on swapfile
set undofile                    " turn on undo file
set undolevels=1000             " save X undo levels
set backupdir=$HOME/var/backup  " backup file location
set directory=$HOME/var/backup  " swapfile location
set undodir=$HOME/var/backup    " undofile location

"  - indenting                                                           {{{2
set tabstop=2      " \t length
set shiftwidth=2   " indenting steps (=0: tabstop)
set softtabstop=2  " <TAB> inserts N spaces|\t if possible
set expandtab      " <TAB> never inserts \t (C-V<TAB> will do)
set autoindent     " copies indent of previous line
set copyindent     " use same structure instead of tab characters
set breakindent    " follow indent when soft-wrapping
set shiftround     " round > and < to multiples of shiftwidth

"  - interface                                                           {{{2
set clipboard=unnamed,unnamedplus  " copy/paste to + and * registers
set cursorline         " highlight cursor position line
set fillchars=fold:\   " set character to fill up fold lines
set foldmethod=marker  " set the folding method
set hidden             " hide buffer if opening new (avoid save/undo)
set modelineexpr       " allow modeline expressions
set relativenumber     " show relative line numbers
set scrolloff=5        " minimum context around cursor
set showmatch          " highlight matching ( )
set noshowmode         " show mode under statusline
set splitbelow         " when split, new window below
set splitright         " when split, new window right
set termguicolors      " use 24bit colors
set title              " automatically set window title
set virtualedit=all    " allow cursor to travel anywhere
if &diff | set nowrap so=0  | endif
colorscheme default

" basic shortcut key maps
nnoremap ; :
let mapleader = ' '    " set the leader key

" highlight 1+ column after textwidth
let &colorcolumn = '+' . join(range(1, 300), ',+')

" make sure we use python3
let python3_host_prog = '/usr/bin/python3'
let loaded_python_provider = 0 " disable python2

"  - searching and completion                                            {{{2
set ignorecase                  " ignore case when searching
set smartcase                   " only ignore case if all lowercase
set wildmode=longest:full,full  " how to complete multiple matches
set spelllang=en_us             " set default spell language

"  - text formatting                                                     {{{2
set textwidth=77            " text width length
set cpoptions+=J            " a sentence will end with two spaces
set showbreak=│\            " showbreak when soft-wrapping
set list                    " list mode :h 'list' 'listchars'
set listchars=tab:.…,trail:•,extends:»,precedes:«,nbsp:~
set formatoptions+=ornlmB   " formatting options, :h fo-table
set formatlistpat=^\\s*\\(\\d\\+[\\]:.)}\\t\ ]\\\\|-\\\\|·\\)\\s*

" • plugins                                                              {{{1
"  - ensure plugin manager is installed and loaded                       {{{2
let s:packdir = stdpath('data') . '/site/pack/'
let s:packer = s:packdir . '/packer/opt/packer.nvim'
if !isdirectory(s:packer)
  echom 'Cloning packer.nvim'
  silent exe '!git clone git@github.com:wbthomason/packer.nvim '.s:packer
  mode
endif

"  - if available, load the plugins                                      {{{2
if isdirectory(s:packer)
  packadd packer.nvim

  "  - automatically reload and compile plugins when config changes
  let s:plugins = stdpath('config').'/lua/plugins/setup.lua'
  exe 'autocmd UserGroup BufWritePost '.s:plugins.' luafile <afile>'
  exe 'autocmd UserGroup BufWritePost '.s:plugins.' PackerCompile'

  "  - setup and load plugins
  let packer = s:packdir . '/loader/start/packer/plugin/pack.vim'
  lua require('plugins.setup')
  lua require('plugins.load')
endif

" • utils                                                                {{{1
lua require('utils')
