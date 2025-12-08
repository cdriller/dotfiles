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
vim.o.autoindent = true
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

-- ###########
-- # Globals #
-- ###########
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable space in normal mode (nnoremap <space> <nop>)
vim.keymap.set("n", "<space>", "<nop>", { noremap = true })
vim.keymap.set("n", "\\", "<nop>", { noremap = true })

-- ###########
-- # Keymaps #
-- ###########
vim.keymap.set("n", "<leader><CR>", ":so %<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Tab>", ":b #<CR>", { silent = true })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)


-- Setup lazy.nvim
require("lazy").setup({
    defaults = {
        lazy = true,
    },
    spec = { { import = "plugins" } },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = {
        missing = true,
        colorscheme = { "gruvbox" },
    },
    -- automatically check for plugin updates
    checker = { enabled = true },
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(_)
        vim.keymap.set("n", "grc", vim.lsp.buf.declaration)
        vim.keymap.set("n", "grd", vim.lsp.buf.definition)
    end
})
