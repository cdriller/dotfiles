local keys = require("keys")

return {
    src = "https://github.com/lewis6991/gitsigns.nvim",
    setup = function ()
        require("gitsigns").setup({
            on_attach = keys.gitsigns,
        })
    end,
}
