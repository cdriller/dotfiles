return {
    src = "https://github.com/christoomey/vim-tmux-navigator",
    setup = function ()
        -- Disable tmux navigator default mappings
        vim.g.tmux_navigator_no_mappings = 1

        vim.keymap.set("n", "<M-h>", ":<C-U>TmuxNavigateLeft<CR>", { silent = true, noremap = true })
        vim.keymap.set("n", "<M-j>", ":<C-U>TmuxNavigateDown<CR>", { silent = true, noremap = true })
        vim.keymap.set("n", "<M-k>", ":<C-U>TmuxNavigateUp<CR>", { silent = true, noremap = true })
        vim.keymap.set("n", "<M-l>", ":<C-U>TmuxNavigateRight<CR>", { silent = true, noremap = true })
    end,
}
