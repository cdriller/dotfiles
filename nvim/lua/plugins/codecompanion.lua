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
            "<leader>aa",
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
            "<Leader>ac",
            "<cmd>CodeCompanionChat Toggle<CR>",
            desc = "Toggle a chat buffer",
            mode = { "n", "v" },
        },
        {
            "<Leader>ac",
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
