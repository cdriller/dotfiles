return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    config = function()
        local install = require("nvim-treesitter.install")
        install.install({ "python", "lua", "c", "bash", "markdown" })
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match)
                if lang then
                    install.install({ lang })
                end
            end
        })
    end
}
