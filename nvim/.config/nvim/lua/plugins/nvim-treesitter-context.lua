return {
    src = "https://github.com/nvim-treesitter/nvim-treesitter-context",
    setup = function ()
        require("treesitter-context").setup({ max_lines = 0 })
    end,
}
