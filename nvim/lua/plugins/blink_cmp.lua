return {
    "saghen/blink.cmp",
    build = "cargo build --release",
    dependencies = { "L3MON4D3/LuaSnip" },
    event = "InsertEnter",
    opts = {
        appearance = {
            kind_icons = {
                Text = "T",
                Method = "F",
                Function = "F",
                Constructor = "F",

                Field = "P",
                Variable = "V",
                Property = "P",

                Class = "C",
                Interface = "C",
                Struct = "C",
                Module = "M",

                Unit = "󰪚",
                Value = "󰦨",
                Enum = "󰦨",
                EnumMember = "󰦨",

                Keyword = "󰻾",
                Constant = "󰏿",

                Snippet = "S",
                Color = "󰏘",
                File = "󰈔",
                Reference = "󰬲",
                Folder = "󰉋",
                Event = "󱐋",
                Operator = "󰪚",
                TypeParameter = "󰬛",
            },
        },
        snippets = { preset = "luasnip" },
        keymap = {
            preset = "enter",
            ['<Down>'] = {'show_and_insert', 'select_next', 'fallback' },
        },
        fuzzy = {
            implementation = "prefer_rust_with_warning",
        },
        completion = {
            menu = {
                auto_show = function()
                    local filetypes = {
                        tex = true,
                        plaintex = true,
                        codecompanion = true,
                        gitcommit = true
                    }
                    if filetypes[vim.bo.filetype] then
                        return false
                    end
                    return true
                end,
            },
            documentation = { auto_show = true, auto_show_delay_ms = 500 },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
    },
}
