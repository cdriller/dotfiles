return {
    "morhetz/gruvbox",
    lazy = false,
    priority = 1000,
    config = function ()
        vim.cmd("colorscheme gruvbox")

        local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg

        vim.api.nvim_set_hl(0, "SignColumn", { bg = normal_bg })
    end,
}
