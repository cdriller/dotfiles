## Why

The Neovim config currently bootstraps and manages all 17 plugins through `lazy.nvim`, cloned and bootstrapped manually at the top of `init.lua`. Neovim now ships a built-in package manager (`vim.pack`, available from Neovim 0.12), so this config can drop the third-party plugin manager entirely and manage plugins with native Neovim tooling instead, reducing external dependencies and bootstrap complexity.

## What Changes

- **BREAKING**: Remove the `lazy.nvim` bootstrap block from `init.lua` (git-clone-on-first-run logic) and replace it with `vim.pack.add({...})` calls declaring all plugins.
- **BREAKING**: Convert every file under `nvim/.config/nvim/lua/plugins/*.lua` from a `lazy.nvim` plugin spec (table with `event`/`cmd`/`ft`/`keys`/`opts`/`config`/`dependencies`/`build` fields) to a `vim.pack` spec (`{ src, version, name }`) plus an explicit `require(...).setup(...)` call, since `vim.pack` has no spec-table DSL.
- **BREAKING**: Drop lazy-loading behavior. All plugins load eagerly at startup via `vim.pack.add`, since `vim.pack` has no equivalent to `lazy.nvim`'s `event`/`cmd`/`ft`/`keys` triggers. (Decided with the user: eager loading is acceptable given the modest plugin count.)
- Drop `lazy.nvim`'s automatic `build` hook. For `blink.cmp` (`cargo build --release`) and `nvim-treesitter` (`:TSUpdate`), document a manual one-time step the user runs after adding or updating the plugin. (Decided with the user: no scripted automation for this.)
- Remove the `lazy-lock.json`-style reproducibility mechanism; reproducible installs now come from pinning an explicit `version` (tag/branch/commit) directly in each plugin's `vim.pack.add` spec, where a pin is wanted.
- Preserve all existing plugin configuration values (options, keymaps, autocmds, colorscheme setup, treesitter install list, lualine theme, etc.) unchanged — only the loading/bootstrap mechanism changes, not plugin behavior or keybindings.
- Keep the two currently-deleted plugin spec files (`neogen.lua`, `nvim-lspconfig.lua`) deleted; they are not part of this migration's scope and will not be recreated in either format.

## Capabilities

### New Capabilities

- `nvim-plugin-management`: Neovim SHALL install, load, and configure all editor plugins using the built-in `vim.pack` package manager instead of the third-party `lazy.nvim` plugin manager, with no automatic bootstrap step required before plugins are available.

### Modified Capabilities

(none — no existing capability spec covers plugin management today)

## Impact

- `nvim/.config/nvim/init.lua`: remove `lazy.nvim` bootstrap and `require("lazy").setup(...)` call; add `vim.pack.add(...)` declarations.
- All 17 files under `nvim/.config/nvim/lua/plugins/`: rewritten from `lazy.nvim` spec tables to `vim.pack` specs + explicit setup calls.
- Any plugin relying on `lazy.nvim`'s lazy-loading triggers (`blink.cmp` on `InsertEnter`, `fzf-lua` on `cmd`/keys, `gitsigns.nvim`/`harpoon`/`lualine`/`which-key`/`vim-fugitive`/`vim-unimpaired` on `VeryLazy`, `render-markdown.nvim` on `ft`, `nvim-treesitter`/`nvim-treesitter-context` on `event`, `vim-mundo`/`vim-tmux_navigator` on `keys`) now loads eagerly at startup instead.
- `blink.cmp`'s `cargo build --release` and `nvim-treesitter`'s `:TSUpdate` build steps are no longer run automatically on install/update; this becomes a documented manual step.
- No changes to keybindings, colorscheme, LSP configuration (`lsp/*.lua`), or any other part of the Neovim config outside of plugin declaration/bootstrap.
