local vim = vim

vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function (args)
        vim.bo[args.buf].formatexpr = nil
    end,
})

vim.lsp.enable("pyright")
vim.lsp.enable("solidity_custom")
vim.lsp.enable("vtsls")
vim.lsp.enable("clangd")
vim.lsp.enable("html")
vim.lsp.enable("lua_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("jdtls")
vim.lsp.enable("tinymist")
