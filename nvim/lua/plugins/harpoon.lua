return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<C-e>",       function () require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,    mode = "n", noremap = true, silent = true },
        { "<leader>1",       function () require("harpoon"):list():select(1) end,    mode = "n", noremap = true, silent = true },
        { "<leader>2",       function () require("harpoon"):list():select(2) end,    mode = "n", noremap = true, silent = true },
        { "<leader>3",       function () require("harpoon"):list():select(3) end,    mode = "n", noremap = true, silent = true },
        { "<leader>fah",       function () require("harpoon"):list():add() end,    mode = "n", noremap = true, silent = true },
    },
    config = true
}
