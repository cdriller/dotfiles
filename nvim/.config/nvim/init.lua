vim.filetype.add({
    extension = {
        h = "c",
        tex = "tex",
        lds = "ld",
    },
})

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
vim.o.undodir = os.getenv("XDG_STATE_HOME") .. "nvim/undo"
vim.o.undolevels = 10000
vim.o.undoreload = 10000

-- Tabs and indentation
vim.o.autoindent = true
vim.o.shiftwidth = 0
vim.o.list = true

-- No swap file
vim.o.swapfile = false

vim.o.ignorecase = true
vim.o.smartcase = true

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

vim.o.signcolumn = "yes:2"

vim.o.completeopt = "popup,menuone,noinsert"

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false
-- vim.opt.foldlevel = 99
-- vim.opt.foldlevelstart = 99
-- vim.opt.foldnestmax = 4
-- vim.opt.foldcolumn = "1"
-- vim.opt.foldtext = ""

-- ##############
-- # Leader Key #
-- ##############
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading plugins so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- Disable space and \ so they can be used as leader and localleader
vim.keymap.set("n", "<space>", "<nop>", { noremap = true })
vim.keymap.set("n", "\\", "<nop>", { noremap = true })

-- ###########
-- # Plugins #
-- ###########
-- Managed with Neovim's built-in `vim.pack` package manager (no third-party
-- plugin manager). Each file under `lua/plugins/` returns
-- `{ src, version?, name?, setup? }`; order matters only for `gruvbox`, which
-- must run its `setup()` (colorscheme + derived highlight group) before
-- anything else, so it is listed first.
--
-- Manual build steps (vim.pack runs no build hooks automatically):
--   - blink.cmp: run `cargo build --release` inside its plugin directory
--     (under `vim.fn.stdpath("data") .. "/site/pack/core/opt/blink.cmp"`).
--   - nvim-treesitter: run `:TSUpdate` after installing or updating it.
local plugins = {
    "gruvbox",
    "blink-lib",
    "luasnip",
    "blink_cmp",
    "nvim-web-devicons",
    "todo-comments",
    "fzf",
    "gitsigns",
    "harpoon",
    "lualine",
    "mason",
    "nvim-treesitter-context",
    "nvim-treesitter",
    "plenary",
    "render_markdown",
    "tabular",
    "vim_mundo",
    "vim_tmux_navigator",
    "vim-fugitive",
    "vim-unimpaired",
    "which-key",
}

local plugin_modules = {}
local plugin_specs = {}
for _, plugin_name in ipairs(plugins) do
    local mod = require("plugins." .. plugin_name)
    plugin_modules[#plugin_modules + 1] = mod
    plugin_specs[#plugin_specs + 1] = {
        src = mod.src,
        version = mod.version,
        name = mod.name,
    }
end

-- `load = true`: vim.pack.add() defaults `load` to false while init.lua is
-- still sourcing, which would leave every plugin's `plugin/`/`ftdetect`
-- scripts unsourced (e.g. vim-fugitive's `:Git`, vim-mundo's `:MundoToggle`,
-- vim-tmux-navigator's `:TmuxNavigate*`, vim-unimpaired's mappings).
vim.pack.add(plugin_specs, { load = true })

for _, mod in ipairs(plugin_modules) do
    if mod.setup then
        mod.setup()
    end
end

require "lsp"

vim.schedule(function ()
   require "keys".global()
end)
