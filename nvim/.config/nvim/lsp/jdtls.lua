---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local root_dir = config.root_dir or vim.fn.getcwd()
    local hash = vim.fn.sha256(root_dir):sub(1, 12)
    local data_dir = vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. hash
    vim.fn.mkdir(data_dir, "p")
    return vim.lsp.rpc.start({ "jdtls", "-data", data_dir }, dispatchers)
  end,
  filetypes = { "java" },
  root_dir = function(bufnr, on_dir)
    local markers = { "pom.xml", "build.gradle", "build.gradle.kts", "gradlew", "mvnw", ".git" }
    on_dir(vim.fs.root(bufnr, markers))
  end,
}
