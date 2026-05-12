vim.lsp.enable("clangd")
vim.keymap.set("n", "<localleader>a", ":LspClangdSwitchSourceHeader<CR>", { silent = true })
