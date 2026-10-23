## Why

Neovim's native LSP loading convention auto-discovers server configs from `lsp/<name>.lua` files on the runtimepath; this config already uses that mechanism for `jdtls`, `solidity_custom`, and `vtsls`. The remaining five servers (`pyright`, `clangd`, `html`, `lua_ls`, `tinymist`) are still defined inline inside `lua/lsp.lua` via a custom `load_lsps()` helper, so the same kind of config is split across two different mechanisms depending on which server you're looking at. Unifying on the `lsp/` convention removes that split and the now-redundant helper.

## What Changes

- Extract the inline configs for `pyright`, `clangd`, `html`, `lua_ls`, and `tinymist` out of `lua/lsp.lua` into their own files: `lsp/pyright.lua`, `lsp/clangd.lua`, `lsp/html.lua`, `lsp/lua_ls.lua`, `lsp/tinymist.lua` — each returning a `vim.lsp.Config` table, matching the existing `lsp/jdtls.lua` / `lsp/vtsls.lua` / `lsp/solidity_custom.lua` pattern.
- Reduce `lua/lsp.lua` to: the existing `LspDetach` autocmd (unrelated, left as-is) plus a flat list of `vim.lsp.enable(...)` calls, one per server, for all eight servers (`pyright`, `solidity_custom`, `vtsls`, `clangd`, `html`, `lua_ls`, `rust_analyzer`, `jdtls`, `tinymist`).
- Remove the `load_lsps()` helper function, since it exists only to bridge inline config tables into `lsp.config[name]` + `lsp.enable(name)`; plain `vim.lsp.enable("<name>")` calls now suffice because every server's config lives in `lsp/`.
- No config content changes — each extracted table's fields (`cmd`, `filetypes`, `root_markers`/`root_dir`, `on_init`, `settings`, etc.) are moved verbatim, not altered.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — this is a pure file-organization refactor; no LSP server's observable behavior, activation trigger, or configuration changes, so no spec-level requirement changes. `skip_specs: true` is set in this change's `.openspec.yaml`.)

## Impact

- `nvim/.config/nvim/lua/lsp.lua` — shrinks to autocmd + enable-calls only.
- `nvim/.config/nvim/lsp/pyright.lua`, `clangd.lua`, `html.lua`, `lua_ls.lua`, `tinymist.lua` — new files.
- `nvim/.config/nvim/lua/keys.lua:149` — the `<leader>nl` "Open lsp config" keybinding still opens `lua/lsp.lua`, but that file will no longer show individual server configs, only the enable list. Left as-is (out of scope), noted for awareness.
- No other files reference `lua/lsp.lua`'s internals; `init.lua:112` (`require "lsp"`) is unaffected since the module name/path doesn't change.
