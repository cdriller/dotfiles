call plug#begin("$XDG_CONFIG_HOME/nvim/plugged")
    Plug 'chrisbra/csv.vim'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'simnalamburt/vim-mundo'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-unimpaired'
call plug#end()

augroup filetype_csv
    autocmd!
    autocmd BufRead,BufWritePost *.csv :%ArrangeColumn!
    autocmd BufWritePre *.csv :%UnArrangeColumn
augroup END

nnoremap <space> <nop>
let mapleader = "\<space>"

set clipboard+=unnamedplus
set relativenumber
set number

" no swap file
set noswapfile

noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

set undofile
set undodir=$HOME/.config/nvim/undo
set undolevels=10000
set undoreload=10000

" tabstop
set softtabstop=4
set shiftwidth=4
set noexpandtab
set autoindent
