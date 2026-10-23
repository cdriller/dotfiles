local keys = require("keys")

return {
    src = "https://github.com/folke/which-key.nvim",
    setup = function ()
        keys.which_key()
        require("which-key").setup({
            preset = "helix",
            icons = { mappings = false },
            delay = 300,
            win = { border = "single" },
        })
    end,
}
