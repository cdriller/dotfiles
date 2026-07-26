return {
    "ibhagwan/fzf-lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "folke/todo-comments.nvim",
    },
    cmd = {
        "FzfLua",
    },
    keys = {
        { "<leader>gg",       function () FzfLua.live_grep() end,                   mode = "n", noremap = true, silent = true, desc = "grep" },
    },
    opts = {
        winopts = {
            fullscreen = false,
        },
    },
}
