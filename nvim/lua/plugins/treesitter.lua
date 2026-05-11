return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
        event = { "VeryLazy" },
        cmd = { "TSUpdate", "TSInstall", "TSUninstall" },
        build = ":TSUpdate",
        config = function ()
            -- config and not opts because it is nvim-treesitter.configs and not nvim-treesitter
            ---@diagnostic disable-next-line: missing-fields
            require "nvim-treesitter.configs".setup {
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
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                },
            }
            -- vim.opt.foldmethod = "expr"
            -- vim.opt.foldnestmax = 1
            -- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
    },
}
