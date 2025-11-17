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
        { "<leader>fb",       function () require("fzf-lua").buffers() end,    mode = "n", noremap = true, silent = true },
        { "<leader><leader>", function () FzfLua.global() end,                 mode = "n", noremap = true, silent = true },
        { "<leader>fg",       function () FzfLua.grep() end,                   mode = "n", noremap = true, silent = true },
        { "<leader>ff",       function () FzfLua.files({ cwd = "$HOME" }) end, mode = "n", noremap = true, silent = true },
        { "<leader>fF",       function () FzfLua.files({ cwd = "/" }) end,     mode = "n", noremap = true, silent = true },
        { "<leader>ft",       ":TodoFzfLua<CR>",                               mode = "n", noremap = true, silent = true },
    },
    opts = {
        winopts = {
            fullscreen = true,
        },
    },
}
