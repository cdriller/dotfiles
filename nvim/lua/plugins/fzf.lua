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
        { "<leader>sg",       function () FzfLua.live_grep() end,                   mode = "n", noremap = true, silent = true },
        { "<leader>ss",       function () FzfLua.lsp_document_symbols() end,                   mode = "n", noremap = true, silent = true },
        { "<leader>sS",       function () FzfLua.lsp_live_workspace_symbols() end,                   mode = "n", noremap = true, silent = true },
        { "<leader>sk",       function () FzfLua.keymaps() end,     mode = "n", noremap = true, silent = true },
        { "<leader>ff",       function () FzfLua.files({ cwd = "$HOME" }) end, mode = "n", noremap = true, silent = true },
        { "<leader>fF",       function () FzfLua.files({ cwd = "/" }) end,     mode = "n", noremap = true, silent = true },
    },
    opts = {
        winopts = {
            fullscreen = true,
        },
    },
}
