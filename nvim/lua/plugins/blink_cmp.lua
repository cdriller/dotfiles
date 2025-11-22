return {
    "saghen/blink.cmp",
    build = "cargo build --release",
    dependencies = { "L3MON4D3/LuaSnip" },
    event = "InsertEnter",
    opts = {
        snippets = { preset = "luasnip" },
        keymap = { preset = "enter" },
        fuzzy = {
            implementation = "prefer_rust_with_warning",
        },
        completion = {
            menu = {
                auto_show = function()
                    if vim.bo.filetype == "plaintex" then
                        return false
                    end
                    return true
                end,
            },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
    },
}
