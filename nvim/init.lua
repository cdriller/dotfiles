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
    spec = {

        -- FZF
        {
            "junegunn/fzf",
            build = "./install --bin",
        }, -- FZF requires build step
        {
            "junegunn/fzf.vim",
            dependencies = { "junegunn/fzf" },
            keys = {
                { "<leader>fb",       ":Buffers<CR>", mode = "n", noremap = true, silent = true },
                { "<leader><leader>", ":Files<CR>",   mode = "n", noremap = true, silent = true },
                { "<leader>fg",       ":RG<CR>",      mode = "n", noremap = true, silent = true },
                { "<leader>ff",       ":FZF ~<CR>",   mode = "n", noremap = true, silent = true },
                { "<leader>fF",       ":FZF /<CR>",   mode = "n", noremap = true, silent = true },
            },
        },
        -- Git
        { "tpope/vim-fugitive" },
        {
            "lewis6991/gitsigns.nvim",
            opts = {
                on_attach = function (bufnr)
                    local gitsigns = require("gitsigns")

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map("n", "]c", function ()
                        if vim.wo.diff then
                            vim.cmd.normal({ "]c", bang = true })
                        else
                            gitsigns.nav_hunk("next")
                        end
                    end)

                    map("n", "[c", function ()
                        if vim.wo.diff then
                            vim.cmd.normal({ "[c", bang = true })
                        else
                            gitsigns.nav_hunk("prev")
                        end
                    end)

                    -- Actions
                    map("n", "<leader>hs", gitsigns.stage_hunk)
                    map("n", "<leader>hr", gitsigns.reset_hunk)

                    map("v", "<leader>hs", function ()
                        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end)

                    map("v", "<leader>hr", function ()
                        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end)

                    map("n", "<leader>hS", gitsigns.stage_buffer)
                    map("n", "<leader>hR", gitsigns.reset_buffer)
                    map("n", "<leader>hp", gitsigns.preview_hunk)
                    map("n", "<leader>hi", gitsigns.preview_hunk_inline)

                    map("n", "<leader>hb", function ()
                        gitsigns.blame_line({ full = true })
                    end)

                    map("n", "<leader>hd", gitsigns.diffthis)

                    map("n", "<leader>hD", function ()
                        gitsigns.diffthis("~")
                    end)

                    map("n", "<leader>hQ", function () gitsigns.setqflist("all") end)
                    map("n", "<leader>hq", gitsigns.setqflist)

                    -- Toggles
                    map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
                    map("n", "<leader>tw", gitsigns.toggle_word_diff)

                    -- Text object
                    map({ "o", "x" }, "ih", gitsigns.select_hunk)
                end,
            }
        }, -- has Lua config
        { "tpope/vim-unimpaired" },

        -- Undo Tree
        {
            "simnalamburt/vim-mundo",
            keys = {
                { "<leader>ut", ":MundoToggle<CR>", mode = "n", noremap = true, silent = true },
            },
        },
        -- Colorscheme
        {
            "morhetz/gruvbox",
            lazy = false,
            priority = 1000,
            config = function()
                vim.cmd("colorscheme gruvbox")

                local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg

                vim.api.nvim_set_hl(0, "SignColumn", { bg = normal_bg })
            end
        }, -- load early

        -- Statusline
        {
            "nvim-lualine/lualine.nvim",
            opts = function()
                local lualine_theme = require("lualine.themes.gruvbox")
                lualine_theme.insert = lualine_theme.normal
                lualine_theme.visual = lualine_theme.normal
                lualine_theme.replace = lualine_theme.normal
                lualine_theme.command = lualine_theme.normal
                lualine_theme.inactive = lualine_theme.normal

                return {
                    options = {
                        icons_enabled = true,
                        theme = lualine_theme,
                        component_separators = { left = "", right = "" },
                        section_separators = { left = "", right = "" },
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
                                "WinEnter",
                                "BufEnter",
                                "BufWritePost",
                                "SessionLoadPost",
                                "FileChangedShellPost",
                                "VimResized",
                                "Filetype",
                                "CursorMoved",
                                "CursorMovedI",
                                "ModeChanged",
                            },
                        },
                    },
                    sections = {
                        lualine_a = {},
                        lualine_b = { "branch", { "filename", newfile_status = true } },
                        lualine_c = { "filetype", "fileformat", "encoding", "filesize", "%=", "diff", "diagnostics", "lsp_status" },
                        lualine_x = { "location", "%L" },
                        lualine_y = {},
                        lualine_z = {},
                    },
                    inactive_sections = {
                        lualine_a = {},
                        lualine_b = {},
                        lualine_c = { "filename" },
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = {},
                    },
                    tabline = {},
                    winbar = {},
                    inactive_winbar = {},
                    extensions = { "fzf", "mundo", "mason", "fugitive", "man" },
                }
            end
        },

        -- Tmux integration
        {
            "christoomey/vim-tmux-navigator",
            init = function (_)
                -- Disable tmux navigator default mappings
                vim.g.tmux_navigator_no_mappings = 1
            end,
            keys = {
                { "<M-h>", ":<C-U>TmuxNavigateLeft<CR>",  mode = "n", silent = true, noremap = true },
                { "<M-j>", ":<C-U>TmuxNavigateDown<CR>",  mode = "n", silent = true, noremap = true },
                { "<M-k>", ":<C-U>TmuxNavigateUp<CR>",    mode = "n", silent = true, noremap = true },
                { "<M-l>", ":<C-U>TmuxNavigateRight<CR>", mode = "n", silent = true, noremap = true },
            },
        },
        { "wellle/tmux-complete.vim" },
        { "tmux-plugins/vim-tmux" },

        -- Treesitter
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function ()
                -- config and not opts because it is nvim-treesitter.configs and not nvim-treesitter 
                ---@diagnostic disable-next-line: missing-fields
                require'nvim-treesitter.configs'.setup {
                    auto_install = true,
                    highlight = {
                        enable = true,
                        additional_vim_regex_highlighting = false,
                    },
                    incremental_selection = {
                        enable = true,
                        keymaps = {
                            init_selection = "gnn", -- set to `false` to disable one of the mappings
                            node_incremental = "gnn",
                            scope_incremental = "grc",
                            node_decremental = "gnm",
                        },
                    },
                    indent = {
                        enable = true,
                    },
                }
        end
        },
        -- LSP
        {
            "mason-org/mason.nvim",
            config = true,
        },
        {
            "neovim/nvim-lspconfig",
        },

        -- Debugging
        {
            "mfussenegger/nvim-dap",
            keys = {
                { "<leader>d", function () require("dap").continue() end,         desc = "DAP: Start/Continue" },
                { "<Down>",    function () require("dap").step_over() end,        desc = "DAP: Step Over" },
                { "<Right>",   function () require("dap").step_into() end,        desc = "DAP: Step Into" },
                { "<Left>",    function () require("dap").step_out() end,         desc = "DAP: Step Out" },
                { "<leader>b", function () require("dap").toggle_breakpoint() end, desc = "DAP: Toggle Breakpoint" },
                { "<leader>B", function () require("dap").set_breakpoint() end,   desc = "DAP: Set Breakpoint" },
                {
                    "<leader>lp",
                    function ()
                        require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
                    end,
                    desc = "DAP: Set Log Point",
                },
                { "<leader>dr", function () require("dap").repl.open() end, desc = "DAP: Open REPL" },
                { "<leader>dl", function () require("dap").run_last() end, desc = "DAP: Run Last" },
                {
                    "<leader>dh",
                    function () require("dap.ui.widgets").hover() end,
                    mode = { "n", "v" },
                    desc = "DAP: Hover",
                },
                {
                    "<leader>dp",
                    function () require("dap.ui.widgets").preview() end,
                    mode = { "n", "v" },
                    desc = "DAP: Preview",
                },
                {
                    "<leader>df",
                    function ()
                        local widgets = require("dap.ui.widgets")
                        widgets.centered_float(widgets.frames)
                    end,
                    desc = "DAP: Show Frames",
                },
                {
                    "<leader>ds",
                    function ()
                        local widgets = require("dap.ui.widgets")
                        widgets.centered_float(widgets.scopes)
                    end,
                    desc = "DAP: Show Scopes",
                },
            },
            config = function ()
                local dap = require("dap")
                dap.adapters.gdb = {
                    type = "executable",
                    command = "gdb",
                    args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
                }

                dap.configurations.c = {
                    {
                        name = "Launch",
                        type = "gdb",
                        request = "launch",
                        program = function ()
                            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                        end,
                        args = {}, -- provide arguments if needed
                        cwd = "${workspaceFolder}",
                        stopAtBeginningOfMainSubprogram = false,
                    },
                    {
                        name = "Select and attach to process",
                        type = "gdb",
                        request = "attach",
                        program = function ()
                            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                        end,
                        pid = function ()
                            local name = vim.fn.input("Executable name (filter): ")
                            return require("dap.utils").pick_process({ filter = name })
                        end,
                        cwd = "${workspaceFolder}",
                    },
                    {
                        name = "Attach to gdbserver :1234",
                        type = "gdb",
                        request = "attach",
                        target = "localhost:1234",
                        program = function ()
                            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                        end,
                        cwd = "${workspaceFolder}",
                    },
                }
            end,
        },

        -- Snippets
        { "rafamadriz/friendly-snippets" },

        {
            "saghen/blink.cmp",
            build = "cargo build --release",
            opts = {
                keymap = { preset = "enter" },
                fuzzy = {
                    implementation = "prefer_rust_with_warning",
                },
            }
        },
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = {
        missing = true,
        colorscheme = { "habamax" },
    },
    -- automatically check for plugin updates
    checker = { enabled = true },
})



-- TODO: move this in a dedicated lsp/lua_ls.lua file
vim.lsp.config("lua_ls", {
    on_init = function (client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath("config")
                and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
            then
                return
            end
        end
        -- lua language server is super confused when editing lua files in the config
        -- and raises a lot of [duplicate-doc-field] warnings
        local runtime_files = vim.api.nvim_get_runtime_file("", true)
        for k, v in ipairs(runtime_files) do
            if v == "/home/my-login/.config/nvim/after" or v == "/home/my-login/.config/nvim" then
                table.remove(runtime_files, k)
            end
        end

        table.insert(runtime_files, "${3rd}/luv/library")

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using (most
                -- likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
                -- Tell the language server how to find Lua modules same way as Neovim
                -- (see `:h lua-module-load`)
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua",
                },
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = runtime_files,
                -- library = {
                --   vim.env.VIMRUNTIME,
                --   -- Depending on the usage, you might want to add additional paths
                --   -- here.
                --   '${3rd}/luv/library'
                --   -- '${3rd}/busted/library'
                -- }
                -- Or pull in all of 'runtimepath'.
                -- NOTE: this is a lot slower and will cause issues when working on
                -- your own configuration.
                -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                -- library = {
                --   vim.api.nvim_get_runtime_file('', true),
                -- }
            },
        })
    end,
    settings = {
        Lua = {},
    },
})

-- TODO: create filetype configs
vim.lsp.enable("lua_ls")

vim.lsp.enable("clangd")
vim.keymap.set("n", "<localleader>a", ":LspClangdSwitchSourceHeader<CR>", { silent = true })

