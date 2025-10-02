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

    " Compiler and linter
    "Plug 'neomake/neomake'

    Plug 'morhetz/gruvbox' " Theme

    Plug 'nvim-lualine/lualine.nvim' " Status bar

    "tmux
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'wellle/tmux-complete.vim'
    Plug 'tmux-plugins/vim-tmux'
    Plug 'tmux-plugins/vim-tmux-focus-events'

    Plug 'jez/vim-superman' " Man pages in Neovim

    Plug 'nvim-treesitter/nvim-treesitter'

    Plug 'mason-org/mason.nvim'

    Plug 'neovim/nvim-lspconfig'
call plug#end()

let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <M-h> :<C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :<C-U>TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :<C-U>TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :<C-U>TmuxNavigateRight<cr>

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
set cursorline
set culopt=both

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

nnoremap <silent> <leader><CR> :so %<CR>

noremap <silent> <leader>ut :MundoToggle<CR> " [u]ndo[t]ree

" FZF
noremap <silent> <leader>fb :Buffers<CR>
noremap <silent> <leader><leader> :Files<CR>
noremap <silent> <leader>fg :RG<CR>
noremap <silent> <leader>ff :FZF ~<CR>
noremap <silent> <leader>fF :FZF /<CR>


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


"###########
"# Gruvbox #
"###########

autocmd vimenter * ++nested colorscheme gruvbox 

" ##############
" # Treesitter #
" ##############
lua << EOF
require'nvim-treesitter.configs'.setup{
    auto_install = true,
    highlight = {
	enable = true,
	additional_vim_regex_highlighting = false
    },
    incremental_selection = {
	enable = true,
	keymaps = {
	    init_selection = "gnn", -- set to `false` to disable one of the mappings
	    node_incremental = "grn",
	    scope_incremental = "grc",
	    node_decremental = "grm",
	},
    },
    indent ={
	enable = true 
    }
}
EOF

lua << EOF

local lualine_theme = require('lualine.themes.gruvbox')
lualine_theme.insert = lualine_theme.normal
lualine_theme.visual = lualine_theme.normal
lualine_theme.replace = lualine_theme.normal
lualine_theme.command = lualine_theme.normal
lualine_theme.inactive = lualine_theme.normal

require('lualine').setup {
    options = {
	icons_enabled = true,
	theme = lualine_theme ,
	component_separators = { left = '', right = ''},
	section_separators = { left = '', right = ''},
	disabled_filetypes = {
	    statusline = {},
	    winbar = {},
	},
	ignore_focus = {},
	always_divide_middle = false,
	always_show_tabline = true,
	globalstatus = true,
	refresh = {
	    statusline = 1000,
	    tabline = 1000,
	    winbar = 1000,
	    refresh_time = 16, -- ~60fps
	    events = {
		'WinEnter',
		'BufEnter',
		'BufWritePost',
		'SessionLoadPost',
		'FileChangedShellPost',
		'VimResized',
		'Filetype',
		'CursorMoved',
		'CursorMovedI',
		'ModeChanged',
		},
	}
	},
	sections = {
	    -- lualine_a = {{'mode', fmt=function(str) return str:sub(1,1) end}},
	    lualine_a = {},
	    lualine_b = { 'branch', {'filename', newfile_status = true }},
	    lualine_c = { 'filetype', 'fileformat',  'encoding', 'filesize', '%=', 'diff', 'diagnostics', 'lsp_status'},
	    lualine_x = { 'location', '%L'},
	    lualine_y = {} ,
	    lualine_z = {},
	    },
	inactive_sections = {
	    lualine_a = {},
	    lualine_b = {},
	    lualine_c = {'filename'},
	    lualine_x = {},
	    lualine_y = {},
	    lualine_z = {}
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {'fzf', 'mundo', 'mason', 'fugitive', 'man'}
}
EOF

lua << EOF
    require("mason").setup()
EOF

lua << EOF
    vim.lsp.enable('vimls')
    vim.lsp.enable('lua_ls')
EOF
    
