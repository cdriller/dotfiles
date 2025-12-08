return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<C-e>",       function () require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,    mode = "n", noremap = true, silent = true },
        { "<C-j>",       function () require("harpoon"):list():select(1) end,    mode = "n", noremap = true, silent = true },
        { "<C-k>",       function () require("harpoon"):list():select(2) end,    mode = "n", noremap = true, silent = true },
        { "<C-l>",       function () require("harpoon"):list():select(3) end,    mode = "n", noremap = true, silent = true },
        { "<C-;>",       function () require("harpoon"):list():select(4) end,    mode = "n", noremap = true, silent = true },
        { "<leader>fah",       function () require("harpoon"):list():add() end,    desc = "add file to harpoon", mode = "n", noremap = true, silent = true },
    },
    opts = {
        settings = {
            save_on_toggle = true,
            sync_on_ui_close = true,
        },
    }
}
