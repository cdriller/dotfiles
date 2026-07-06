return {
    "saghen/blink.cmp",
    build = "cargo build --release",
    dependencies = {
        "L3MON4D3/LuaSnip",
        "saghen/blink.lib"
    },
    version = "1.*",
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
            preset = "none",
            ['<C-n>'] = {'select_next', 'fallback' },
            ['<C-p>'] = {'select_prev', 'fallback' },
            ['<C-y>'] = {'accept', 'fallback' },
            -- Disable Tab for snippet jumping (keep literal Tab)
            -- Snippet keybindings via LuaSnip
            ['<C-k>'] = { 'snippet_forward', 'fallback' },
            ['<C-l>'] = { 'snippet_forward', 'fallback' },
            ['<C-h>'] = { 'snippet_backward', 'fallback' },
        },
        fuzzy = {
            implementation = "prefer_rust_with_warning",
        },
        completion = {
            list = {
                selection = {
                    preselect = true,
                    auto_insert = false,
                },
            },
            menu = {
                auto_show = false,
            },
            documentation = { auto_show = true, auto_show_delay_ms = 500 },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
    },
    config = function(_, opts)
        require('blink.cmp').setup(opts)

        local timer = assert(vim.uv.new_timer())
        local DELAY_MS = 750

        local function start_timer()
            timer:stop()
            timer:start(DELAY_MS, 0, vim.schedule_wrap(function()
                if vim.api.nvim_get_mode().mode == 'i' then
                    require('blink.cmp').show()
                end
            end))
        end

        vim.api.nvim_create_autocmd('TextChangedI', {
            callback = function()
                start_timer()
            end,
        })


        vim.api.nvim_create_autocmd('InsertEnter', {
            callback = function()
                start_timer()
            end,
        })

        vim.api.nvim_create_autocmd('CursorMovedI', {
            callback = function()
                start_timer()
            end,
        })

        vim.api.nvim_create_autocmd('InsertLeave', {
            callback = function()
                timer:stop()
            end,
        })

        vim.api.nvim_create_autocmd('VimLeavePre', {
            callback = function()
                if not timer:is_closing() then timer:close() end
            end,
        })
    end,
}
