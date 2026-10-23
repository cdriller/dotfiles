local keys = require("keys")

return {
    src = "https://github.com/ThePrimeagen/harpoon",
    version = "harpoon2",
    setup = function ()
        keys.harpoon()
        require("harpoon"):setup({
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
            },
        })
    end,
}
