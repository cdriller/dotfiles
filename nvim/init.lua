-- ###########
-- # plugins #
-- ###########
vim.cmd [[
call plug#begin("$XDG_CONFIG_HOME/nvim/plugged")
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'simnalamburt/vim-mundo'
    Plug 'tpope/vim-fugitive'
    Plug 'lewis6991/gitsigns.nvim'

    Plug 'tpope/vim-unimpaired'

    Plug 'morhetz/gruvbox' " Theme

    Plug 'nvim-lualine/lualine.nvim' " Status bar

    "tmux
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'wellle/tmux-complete.vim'
    Plug 'tmux-plugins/vim-tmux'

    Plug 'nvim-treesitter/nvim-treesitter'

    Plug 'mason-org/mason.nvim'

    Plug 'neovim/nvim-lspconfig'
call plug#end()
]]

-- Disable tmux navigator default mappings
vim.g.tmux_navigator_no_mappings = 1
-- Helper function for setting keymaps

-- Map Alt+h/j/k/l to tmux navigator commands in normal mode, silently
vim.keymap.set('n', '<M-h>', ':<C-U>TmuxNavigateLeft<CR>', { silent = true, noremap = true })
vim.keymap.set('n', '<M-j>', ':<C-U>TmuxNavigateDown<CR>', { silent = true, noremap = true })
vim.keymap.set('n', '<M-k>', ':<C-U>TmuxNavigateUp<CR>', { silent = true, noremap = true })
vim.keymap.set('n', '<M-l>', ':<C-U>TmuxNavigateRight<CR>', { silent = true, noremap = true })

-- ###########
-- # options #
-- ###########

-- Clipboard
vim.opt.clipboard:append("unnamedplus")

-- Line numbers and cursor
vim.wo.relativenumber = true
vim.wo.number = true
vim.wo.culopt = "both"

-- Undo options
vim.o.undofile = true
vim.o.undodir = os.getenv("HOME") .. "/.config/nvim/undo"
vim.o.undolevels = 10000
vim.o.undoreload = 10000

-- Tabs and indentation
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.list = true

-- No swap file
vim.o.swapfile = false

vim.o.ignorecase = true
vim.o.smartcase = true

-- ###########
-- # keymaps #
-- ###########

-- Set leader key to space
vim.g.mapleader = ' '

-- Disable space in normal mode (nnoremap <space> <nop>)
vim.keymap.set('n', '<space>', '<nop>', { noremap = true })

-- Reload current file (nnoremap <silent> <leader><CR> :so %<CR>)
vim.keymap.set('n', '<leader><CR>', ':so %<CR>', { noremap = true, silent = true })

-- Toggle Mundo undo tree (noremap <silent> <leader>ut :MundoToggle<CR>)
vim.keymap.set('n', '<leader>ut', ':MundoToggle<CR>', { noremap = true, silent = true })

-- FZF mappings
vim.keymap.set('n', '<leader>fb', ':Buffers<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader><leader>', ':Files<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fg', ':RG<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ff', ':FZF ~<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fF', ':FZF /<CR>', { noremap = true, silent = true })

-- TextEdit might fail if hidden is not set.
vim.o.hidden = true

-- Some servers have issues with backup files, see #649.
vim.o.backup = false
vim.o.writebackup = false

-- Give more space for displaying messages.
vim.o.cmdheight = 2

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.
vim.o.updatetime = 300

-- Don't pass messages to |ins-completion-menu|.
vim.o.shortmess = vim.o.shortmess .. "c"

-- Always show the signcolumn, otherwise it would shift the text each time diagnostics appear/become resolved.
if vim.fn.has("patch-8.1.1564") == 1 then
  -- Recently vim can merge signcolumn and number column into one
  vim.o.signcolumn = "number"
else
  vim.o.signcolumn = "yes"
end

--###########
--# Gruvbox #
--###########
vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = function()
    vim.cmd("colorscheme gruvbox")
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
    local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg

    vim.api.nvim_set_hl(0, "SignColumn", { bg = normal_bg })
    end,
})

-- ##############
-- # Treesitter #
-- ##############
require 'nvim-treesitter.configs'.setup {
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
  indent = {
    enable = true
  }
}


local lualine_theme = require('lualine.themes.gruvbox')
lualine_theme.insert = lualine_theme.normal
lualine_theme.visual = lualine_theme.normal
lualine_theme.replace = lualine_theme.normal
lualine_theme.command = lualine_theme.normal
lualine_theme.inactive = lualine_theme.normal

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = lualine_theme,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
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
    },
  },
  sections = {
    -- lualine_a = {{'mode', fmt=function(str) return str:sub(1,1) end}},
    lualine_a = {},
    lualine_b = { 'branch', { 'filename', newfile_status = true } },
    lualine_c = { 'filetype', 'fileformat', 'encoding', 'filesize', '%=', 'diff', 'diagnostics', 'lsp_status' },
    lualine_x = { 'location', '%L' },
    lualine_y = {},
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = { 'fzf', 'mundo', 'mason', 'fugitive', 'man' }
}

require("mason").setup()

vim.o.completeopt = "popup,menuone,noinsert"

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})

vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
          path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          -- Depending on the usage, you might want to add additional paths
          -- here.
          '${3rd}/luv/library'
          -- '${3rd}/busted/library'
        }
        -- Or pull in all of 'runtimepath'.
        -- NOTE: this is a lot slower and will cause issues when working on
        -- your own configuration.
        -- See https://github.com/neovim/nvim-lspconfig/issues/3189
        -- library = {
        --   vim.api.nvim_get_runtime_file('', true),
        -- }
      }
    })
  end,
  settings = {
    Lua = {}
  }
})

vim.lsp.enable('lua_ls')

require('gitsigns').setup{
  on_attach = function(bufnr)

    vim.o.signcolumn = 'yes:2'

    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hr', gitsigns.reset_hunk)

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hR', gitsigns.reset_buffer)
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hi', gitsigns.preview_hunk_inline)

    map('n', '<leader>hb', function()
      gitsigns.blame_line({ full = true })
    end)

    map('n', '<leader>hd', gitsigns.diffthis)

    map('n', '<leader>hD', function()
      gitsigns.diffthis('~')
    end)

    map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
    map('n', '<leader>hq', gitsigns.setqflist)

    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
    map('n', '<leader>tw', gitsigns.toggle_word_diff)

    -- Text object
    map({'o', 'x'}, 'ih', gitsigns.select_hunk)
  end
}
