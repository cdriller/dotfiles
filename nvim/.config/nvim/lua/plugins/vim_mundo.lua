return {
    src = "https://github.com/simnalamburt/vim-mundo",
    setup = function ()
        vim.keymap.set("n", "<leader>ut", ":MundoToggle<CR>", { noremap = true, silent = true })
    end,
}
