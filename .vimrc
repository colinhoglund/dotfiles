if has('python3')
  silent! python3 1
endif

""" Vundle requirements
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Custom vim bundles
Plugin 'godlygeek/tabular'
Plugin 'hashivim/vim-terraform'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'vim-airline/vim-airline'
Plugin 'w0rp/ale'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

""" Custom tweaks
syntax on                      "syntax highlighting
colorscheme molokai            "change vim color scheme
set backspace=indent,eol,start "allow backspacing over everything in insert mode
set cursorline                 "highlight current line
set history=50                 "keep 50 lines of command line history
set hlsearch                   "highlight matches when searching
set incsearch                  "do incremental searching
set number                     "show line numbers
set ruler                      "show the cursor position all the time
set showcmd                    "display incomplete commands
set wildmenu                   "visual autocomplete for command menu

" set tab spacing
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" airline settings
set laststatus=2
let g:airline#extensions#tabline#enabled = 1
let g:airline_left_sep=''
let g:airline_right_sep=''

" split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" folding
set foldenable        " enable folding
set foldlevelstart=10 " open most folds by default
set foldnestmax=10    " 10 nested fold max
set foldmethod=indent " fold based on indent level
nnoremap <space> za

" move vertically by visual line
nnoremap j gj
nnoremap k gk

" highlight last inserted text
nnoremap gV `[v`]

" CtrlP settings
let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'

" vim-fugitive command mappings
command GB Gblame
command GD Gdiff

" set filetype to python for drone starlark pipelines
au BufRead,BufNewFile *.star set filetype=python

let g:ale_completion_enabled = 1
let g:ale_fix_on_save = 1
" Disable --enable-all flag
" (https://github.com/dense-analysis/ale/issues/3670)
let g:ale_go_golangci_lint_options = ''
let g:ale_linters = {
\   'python': ['flake8', 'pyls'],
\   'go': ['gopls'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'go': ['gofmt', 'goimports'],
\   'python': ['black'],
\   'terraform': ['terraform'],
\   'json': ['jq'],
\   'lua': ['luafmt'],
\}
