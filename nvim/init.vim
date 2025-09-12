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
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " Collection of snippets
    Plug 'honza/vim-snippets'

    " Compiler and linter
    Plug 'neomake/neomake'

    " Theme gruvbox
    Plug 'morhetz/gruvbox'

    " Status bar
    Plug 'itchyny/lightline.vim'

    "tmux
    Plug 'wellle/tmux-complete.vim'
    Plug 'tmux-plugins/vim-tmux'
    Plug 'tmux-plugins/vim-tmux-focus-events'
    Plug 'christoomey/vim-tmux-navigator'

    " Man pages in Neovim
    Plug 'jez/vim-superman'
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

" ###########
" # coc.vim #
" ###########

" Coc extensions (need to install yarn or npm, both available in official repo of Arch Linux)
let g:coc_global_extensions = [
            \ 'coc-snippets',
            \ 'coc-css', 
            \ 'coc-html',
            \ 'coc-json', 
            \]

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
    " Recently vim can merge signcolumn and number column into one
    set signcolumn=number
else
    set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
else
    inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

"###########
"# Neomake #
"###########

" Needs to install shellcheck and vint: `sudo pacman -S shellcheck vint`

" Neomake signs in the gutter
let g:neomake_error_sign = {'text': '', 'texthl': 'NeomakeErrorSign'}
let g:neomake_warning_sign = {
            \   'text': '',
            \   'texthl': 'NeomakeWarningSign',
            \ }
let g:neomake_message_sign = {
            \   'text': '',
            \   'texthl': 'NeomakeWarningSign',
            \ }
let g:neomake_info_sign = {'text': 'ℹ', 'texthl': 'NeomakeInfoSign'}

" update neomake when save file
call neomake#configure#automake('w')

command! -bang -nargs=* -complete=file Make NeomakeProject <args>

" Enable linters
let g:neomake_sh_enabled_makers = ['shellcheck']
"let g:neomake_vim_enabled_makers = ['vint']

"###########
"# Gruvbox #
"###########

autocmd vimenter * ++nested colorscheme gruvbox 

"#############
"# lightline #
"#############

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }
