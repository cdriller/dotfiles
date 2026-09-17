## 1. Extract inline configs into `lsp/`

- [ ] 1.1 Create `nvim/.config/nvim/lsp/pyright.lua` returning the `pyright` config table (`cmd`, `filetypes`, `root_markers`) moved verbatim from `lua/lsp.lua`; verify with `nvim --headless -u NONE -c "lua =dofile('nvim/.config/nvim/lsp/pyright.lua')" -c "qa!"` that it loads without error and returns a table
- [ ] 1.2 Create `nvim/.config/nvim/lsp/clangd.lua` returning the `clangd` config table (`cmd`, `root_markers`, `filetypes`) moved verbatim; verify the same way as 1.1
- [ ] 1.3 Create `nvim/.config/nvim/lsp/html.lua` returning the `html` config table (`cmd`) moved verbatim; verify the same way as 1.1
- [ ] 1.4 Create `nvim/.config/nvim/lsp/lua_ls.lua` returning the `lua_ls` config table (`cmd`, `filetypes`, `on_init`, `settings`) moved verbatim, including the full `on_init` function body; verify the same way as 1.1
- [ ] 1.5 Create `nvim/.config/nvim/lsp/tinymist.lua` returning the `tinymist` config table (`cmd`, `filetypes`, `single_file_support`) moved verbatim; verify the same way as 1.1

## 2. Reduce `lua/lsp.lua` to activation only

- [ ] 2.1 Remove the five inline config tables (`pyright`, `clangd`, `html`, `lua_ls`, `tinymist`) and the `load_lsps()` helper from `lua/lsp.lua`, replacing the `load_lsps { ... }` call with a flat list of `vim.lsp.enable("<name>")` calls for all eight servers: `pyright`, `solidity_custom`, `vtsls`, `clangd`, `html`, `lua_ls`, `rust_analyzer`, `jdtls`, `tinymist`; keep the existing `LspDetach` autocmd untouched
- [ ] 2.2 Verify `nvim/.config/nvim/lua/lsp.lua` has no remaining `lsp.config[...] = ...` assignments and no leftover unused locals (`lsp` local can stay if still referenced by the autocmd/`vim.lsp.enable`, otherwise drop it)

## 3. Verify end-to-end

- [ ] 3.1 Launch Neovim headless against the real config and confirm no startup errors: `nvim --headless -c "qa!"` (using `NVIM_APPNAME` or `-u`/`--cmd` pointed at `nvim/.config/nvim/init.lua` as appropriate for this dotfiles layout) exits cleanly with no Lua tracebacks
- [ ] 3.2 Open one buffer per moved server's filetype (e.g. a `.py`, `.ts`, `.lua`, `.typ`, `.html`, `.c` file) inside Neovim and confirm via `:LspInfo` (or `:checkhealth lsp`) that the corresponding client attaches with the same `cmd`/`filetypes`/`root_dir` behavior as before the refactor
- [ ] 3.3 Confirm `jdtls`, `vtsls`, and `solidity_custom` (the servers already following the `lsp/` convention, untouched by this change) still attach normally, as a regression check that the `load_lsps` removal didn't affect them
