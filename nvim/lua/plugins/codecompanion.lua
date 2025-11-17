return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "zbirenbaum/copilot.lua",
        "ravitemer/mcphub.nvim",
        "MeanderingProgrammer/render-markdown.nvim",
    },
    keys = {
        {
            "<C-a>",
            "<cmd>CodeCompanionActions<CR>",
            desc = "Open the action palette",
            mode = { "n", "v" },
        },
        {
            "<Leader>?",
            "<cmd>CodeCompanion /explain<CR>",
            desc = "Toggle a chat buffer",
            mode = { "v" },
        },
        {
            "<Leader>a",
            "<cmd>CodeCompanionChat Toggle<CR>",
            desc = "Toggle a chat buffer",
            mode = { "n", "v" },
        },
        {
            "<Leader>a",
            "<cmd>CodeCompanionChat Add<CR>",
            desc = "Add code to a chat buffer",
            mode = { "v" },
        },
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    ---@module "codecompanion"
    ---@type CodeCompanion
    opts = {
        extensions = {
            mcphub = {
                callback = "mcphub.extensions.codecompanion",
                opts = {
                    make_vars = true,
                    make_slash_commands = true,
                    show_result_in_chat = true,
                },
            },
        },
    },
}
