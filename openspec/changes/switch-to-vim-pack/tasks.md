## 1. Bootstrap rewrite

- [ ] 1.1 Remove the `lazy.nvim` bootstrap block (git-clone-if-missing, `vim.opt.rtp:prepend(lazypath)`) and the `require("lazy").setup({...})` call from `nvim/.config/nvim/init.lua`, and verify by grepping the file for `lazy` and confirming no match remains.
- [ ] 1.2 Add an explicit ordered Lua list of plugin module names to `init.lua` (gruvbox first, per design.md Decision 1), a loop that `require`s each `plugins.<name>` module and collects its `src`/`version`/`name` into a single `vim.pack.add({...})` call, and a second loop that calls each module's `setup()` if present, in list order; verify by confirming the list contains exactly the 17 plugin module names from `lua/plugins/`.

## 2. Convert plugin files with no setup logic

- [ ] 2.1 Convert `plenary.lua` to return `{ src = "https://github.com/nvim-lua/plenary.nvim" }` and verify `nvim --headless -c 'lua print(vim.inspect(require("plugins.plenary")))' -c 'qa'` prints a table with only a `src` field.
- [ ] 2.2 Convert `tabular.lua` to return `{ src = "https://github.com/godlygeek/tabular" }` and verify the same inspection command against `plugins.tabular`.

## 3. Convert plugin files with simple setup (no options object)

- [ ] 3.1 Convert `gruvbox.lua` to `{ src = "https://github.com/morhetz/gruvbox", setup = function() ... end }`, moving the `vim.cmd("colorscheme gruvbox")` and `SignColumn` highlight override into `setup`; verify by starting Neovim and confirming the gruvbox colorscheme is active (`:colorscheme` shows `gruvbox`) and `:hi SignColumn` shows the overridden background.
- [ ] 3.2 Convert `mason.lua` to `{ src = "https://github.com/mason-org/mason.nvim", setup = function() require("mason").setup() end }` and verify `:Mason` opens the UI.
- [ ] 3.3 Convert `vim-fugitive.lua` to `{ src = "https://github.com/tpope/vim-fugitive" }` (no setup needed) and verify `:G status` runs without an "unknown command" error.
- [ ] 3.4 Convert `vim-unimpaired.lua` to `{ src = "https://github.com/tpope/vim-unimpaired" }` and verify a vim-unimpaired mapping (e.g. `[q`/`]q`) still works in a quickfix-populated buffer.
- [ ] 3.5 Convert `nvim-treesitter-context.lua` to `{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context", setup = function() require("treesitter-context").setup({ max_lines = 0 }) end }` and verify the context header still appears when scrolling inside a deeply nested function.

## 4. Convert plugin files with keymaps/autocmds in setup

- [ ] 4.1 Convert `vim_mundo.lua` to `{ src = "https://github.com/simnalamburt/vim-mundo", setup = function() vim.keymap.set("n", "<leader>ut", ":MundoToggle<CR>", { noremap = true, silent = true }) end }` and verify `<leader>ut` toggles the Mundo window.
- [ ] 4.2 Convert `vim_tmux_navigator.lua` to `{ src = "https://github.com/christoomey/vim-tmux-navigator", setup = function() vim.g.tmux_navigator_no_mappings = 1; vim.keymap.set(...) for all four directions end }` and verify each `<M-h/j/k/l>` mapping navigates between Neovim splits.
- [ ] 4.3 Convert `gitsigns.lua` to `{ src = "https://github.com/lewis6991/gitsigns.nvim", setup = function() require("gitsigns").setup({ on_attach = require("keys").gitsigns }) end }` and verify gitsigns hunks appear in the sign column of a modified file under git.
- [ ] 4.4 Convert `render_markdown.lua` to `{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", setup = function() require("render-markdown").setup() end }` and verify markdown rendering appears when opening a `.md` file (noting `ft`-based lazy-loading is intentionally dropped per proposal.md).

## 5. Convert plugins with multiple dependencies or complex setup

- [ ] 5.1 Convert `luasnip.lua`, pinning an explicit tag in place of the `"v2.*"` range (per design.md Decision 3) and moving all snippet-definition code into `setup`; verify by expanding the `ternary` snippet in a buffer with filetype `all` and the `docstr`/`header`/`log`/`document`/`bspfile` snippets in a C buffer.
- [ ] 5.2 Convert `harpoon.lua` to declare `src`/`branch = "harpoon2"` and a `setup` that calls `require("keys").harpoon()` then `require("harpoon"):setup({...})`; verify harpoon add/toggle keybindings still work.
- [ ] 5.3 Convert `which-key.lua` to declare `src` and a `setup` that calls `require("keys").which_key()` then `require("which-key").setup({...})`; verify `<leader>` shows the which-key popup with the `helix` preset styling.
- [ ] 5.4 Convert `lualine.lua` to declare `src` and a `setup` that builds the same options table (inline, since `opts` is no longer a separate lazy.nvim-merged field) and calls `require("lualine").setup(opts)`; verify the statusline, tabline, and winbar render with the same sections as before.
- [ ] 5.5 Convert `fzf.lua` to declare `src` and dependencies (`nvim-web-devicons`, `todo-comments.nvim`) as their own list entries in `init.lua`'s plugin list, and a `setup` that calls `require("fzf-lua").setup({...})` plus the `<leader>gg` keymap; verify `<leader>gg` launches fzf-lua live grep (noting `cmd`/`keys`-based lazy-loading is intentionally dropped).
- [ ] 5.6 Convert `nvim-treesitter.lua` to declare `src` and a `setup` that runs the existing `install.install({...})` call and registers the `FileType` autocmd; verify opening a Python, Lua, C, bash, or markdown file triggers/has correct syntax highlighting.
- [ ] 5.7 Convert `blink_cmp.lua` to declare `src`, dependencies (`LuaSnip`, `blink.lib`) as their own list entries in `init.lua`'s plugin list, pin an explicit tag in place of the `"1.*"` range (per design.md Decision 3), and a `setup` that calls `require("blink.cmp").setup(opts)` plus the existing autocmd-based auto-show timer logic; verify completion still triggers automatically after a short delay while typing in insert mode.

## 6. Manual build steps and end-to-end verification

- [ ] 6.1 Document the manual build steps (run `cargo build --release` inside blink.cmp's plugin directory; run `:TSUpdate` after installing/updating nvim-treesitter) in a README or comment near the plugin list in `init.lua`, since `vim.pack` runs no build hooks automatically (per proposal.md).
- [ ] 6.2 Delete or rename aside the existing `lazy.nvim` data directory and `lazy-lock.json` (if present), start Neovim fresh, and verify all 17 plugins install automatically via `vim.pack.add` with no errors on startup.
- [ ] 6.3 Run the manual build steps from 6.1 once on the fresh install, then verify blink.cmp completion and nvim-treesitter syntax highlighting both work.
- [ ] 6.4 Walk through every keybinding and behavior listed in the verification steps of tasks 2-5 in one Neovim session and confirm none regressed relative to the pre-migration config.
