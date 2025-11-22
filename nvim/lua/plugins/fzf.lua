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
        { "<leader>bb",       function () require("fzf-lua").buffers() end,    mode = "n", noremap = true, silent = true },
        { "<leader><leader>", function () FzfLua.global() end,                 mode = "n", noremap = true, silent = true },
        { "<leader>ss",       function () FzfLua.live_grep() end,                   mode = "n", noremap = true, silent = true },
        { "<leader>ff",       function () FzfLua.files({ cwd = "$HOME" }) end, mode = "n", noremap = true, silent = true },
        { "<leader>fg",       function () FzfLua.git_status() end, mode = "n", noremap = true, silent = true },
        { "<leader>fF",       function () FzfLua.files({ cwd = "/" }) end,     mode = "n", noremap = true, silent = true },
    },
    opts = {
        winopts = {
            fullscreen = true,
        },
    },
}
