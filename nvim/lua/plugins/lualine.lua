return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function ()
        local lualine_theme = require("lualine.themes.gruvbox")
        lualine_theme.insert = lualine_theme.normal
        lualine_theme.visual = lualine_theme.normal
        lualine_theme.replace = lualine_theme.normal
        lualine_theme.command = lualine_theme.normal
        lualine_theme.inactive = lualine_theme.normal

        return {
            options = {
                icons_enabled = true,
                theme = lualine_theme,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = false,
                always_show_tabline = true,
                globalstatus = true,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                    refresh_time = 16,         -- ~60fps
                    events = {
                        "WinEnter",
                        "BufEnter",
                        "BufWritePost",
                        "SessionLoadPost",
                        "FileChangedShellPost",
                        "VimResized",
                        "Filetype",
                        "CursorMoved",
                        "CursorMovedI",
                        "ModeChanged",
                    },
                },
            },
            sections = {
                lualine_a = {},
                lualine_b = { "branch", { "filename", newfile_status = true } },
                lualine_c = { "filetype", "fileformat", "encoding", "filesize", "%=", "diff", "diagnostics", "lsp_status" },
                lualine_x = { "location", "%L" },
                lualine_y = {},
                lualine_z = {},
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = { "fzf", "mundo", "mason", "fugitive", "man" },
        }
    end,
}
