## Why

Java files currently get LSP support only by accident: `lua/lsp.lua` enables
`jdtls` with no config of its own, so it silently falls back to whatever
default `lsp/jdtls.lua` happens to be on the runtimepath (currently shipped
by the `nvim-lspconfig` plugin). That default doesn't set the per-project
`-data` workspace directory jdtls requires, so it doesn't reliably work
across multiple Java projects. The user wants to fix this the same way
`vtsls` and `solidity_custom` already were: a self-contained `lsp/jdtls.lua`
in their own config, installed and launched without `mason.nvim`.

## What Changes

- Add a hand-written `nvim/.config/nvim/lsp/jdtls.lua` (matching the
  existing `lsp/vtsls.lua` / `lsp/solidity_custom.lua` pattern) that
  defines `cmd`, `filetypes`, `root_dir`, and a per-project `-data`
  workspace directory for jdtls.
- Install the `jdtls` binary via Homebrew (`brew install jdtls`) instead of
  `mason.nvim`, matching how every other LSP binary in this config is
  already sourced (plain command name on `PATH`, not tracked or installed
  by the dotfiles repo itself).
- Keep the `{ name = "jdtls" }` entry in `lua/lsp.lua`'s `load_lsps` list
  as-is; it now picks up the new file instead of `nvim-lspconfig`'s default.
- Out of scope: debugging (DAP), test running, and Java-specific refactor
  code actions (extract variable/method, etc.) — those need the `nvim-jdtls`
  plugin, which this change deliberately does not add, per the "very
  minimal" LSP-only goal. `mason.nvim` itself is not removed from the repo;
  it's simply not used for jdtls.

## Capabilities

### New Capabilities
- `nvim-java-lsp`: Java files in Neovim get LSP features (diagnostics,
  completion, go-to-definition, hover, formatting) via a natively
  configured `jdtls`, installed without `mason.nvim`.

### Modified Capabilities
(none — no existing spec covers Neovim LSP behavior today)

## Impact

- `nvim/.config/nvim/lsp/jdtls.lua` (new file)
- `nvim/.config/nvim/lua/lsp.lua` (no functional change expected, entry
  already present)
- External dependency: `jdtls` (and transitively `openjdk`) installed via
  Homebrew, outside of what this dotfiles repo tracks or installs
  automatically — same convention as `clangd`, `pyright-langserver`,
  `lua-language-server`, etc.
