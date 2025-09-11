" ###########
" # plugins #
" ###########

call plug#begin("$XDG_CONFIG_HOME/nvim/plugged")
    Plug 'chrisbra/csv.vim'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'simnalamburt/vim-mundo'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-unimpaired'
    Plug 'christoomey/vim-tmux-navigator'
call plug#end()

augroup filetype_csv
    autocmd!
    autocmd BufRead,BufWritePost *.csv :%ArrangeColumn!
    autocmd BufWritePre *.csv :%UnArrangeColumn
augroup END

" ###########
" # options #
" ###########

set clipboard+=unnamedplus
set relativenumber
set number

set undofile
set undodir=$HOME/.config/nvim/undo
set undolevels=10000
set undoreload=10000

" tabstop
set softtabstop=4
set shiftwidth=4
set noexpandtab
set autoindent

" no swap file
set noswapfile

" ###########
" # keymaps #
" ###########

nnoremap <space> <nop>
let mapleader = "\<space>"

noremap <leader>ut :MundoToggle<CR> " [u]ndo[t]ree

" FZF
noremap <leader>fb :Buffers<CR>
noremap <leader>ff :Files<CR>
noremap <leader>fF :FZF ~<CR>

