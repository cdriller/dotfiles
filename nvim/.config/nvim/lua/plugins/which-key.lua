local keys = require("keys")

return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      icons = { mappings = false },
      delay = 300,
      win = { border = "single" }
    },
    config = function(_, opts)
        keys.which_key()
        require("which-key").setup(opts)
    end
}
