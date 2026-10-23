return {
    src = "https://github.com/ibhagwan/fzf-lua",
    setup = function ()
        require("fzf-lua").setup({
            winopts = {
                fullscreen = false,
            },
        })
        vim.keymap.set("n", "<leader>gg", function () FzfLua.live_grep() end, { noremap = true, silent = true, desc = "grep" })
    end,
}
