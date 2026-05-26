---@type vim.lsp.Config
return {
  cmd = { "vtsls", "--stdio" },
  init_options = { hostInfo = "neovim" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname ~= "" and fname:find("/frontend/") then
      local frontend = vim.fs.root(bufnr, { "package.json" })
      if frontend then
        on_dir(frontend)
        return
      end
    end

    -- Default: nearest package manager lock (same idea as nvim-lspconfig)
    local markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb" }
    local root = vim.fs.root(bufnr, markers) or vim.fs.root(bufnr, { "tsconfig.json" })
    on_dir(root or vim.fn.getcwd())
  end,
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
    },
  },
}
