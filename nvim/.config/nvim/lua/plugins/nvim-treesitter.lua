return {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    setup = function()
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
