return {
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
}
