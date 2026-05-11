local keys = require("keys")

return {
    "lewis6991/gitsigns.nvim",
    event = "BufEnter",
    opts = {
        on_attach = keys.gitsigns,
    },
}
