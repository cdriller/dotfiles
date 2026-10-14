## Context

See `proposal.md` - Why / What Changes for motivation and the eager-loading and no-build-hook decisions already made with the user.

Current state: `init.lua` bootstraps `lazy.nvim` by git-cloning it if missing, then calls `require("lazy").setup({ spec = { { import = "plugins" } }, ... })`, which auto-discovers every file under `nvim/.config/nvim/lua/plugins/*.lua` and merges each returned spec table (with `event`/`cmd`/`ft`/`keys`/`opts`/`config`/`dependencies`/`build`/`branch`/`version`/`priority` fields) into one plugin graph. 17 plugin files exist today; two others (`neogen.lua`, `nvim-lspconfig.lua`) were already deleted outside this change and stay deleted.

`vim.pack` (Neovim's built-in package manager) exposes only `vim.pack.add(specs, opts)`, `vim.pack.update()`, `vim.pack.del()`, and `vim.pack.get()`. A spec is `{ src = <git-url>, version = <tag|branch|commit>, name = <local-dir-name> }`. There is no `opts`/`config`/`dependencies`/`build`/`event`/`cmd`/`ft`/`keys`/`priority` field - `vim.pack.add` only fetches/checks out code onto the runtimepath. Calling a plugin's `setup()` and wiring keymaps remains the caller's job, same as it always has been for `config` functions, just without the declarative scaffolding.

## Goals / Non-Goals

**Goals:**
- Replace `lazy.nvim` with `vim.pack` while keeping one file per plugin under `lua/plugins/`, so the file-per-plugin structure the user is used to survives.
- Keep the diff per plugin file mechanical and easy to review (same file, same name, new contract).
- Make the one unavoidable manual step (declaring plugin load order) explicit and centralized, rather than scattered.

**Non-Goals:**
- Do not re-implement lazy-loading (decided: eager loading everywhere).
- Do not script build-hook automation for `blink.cmp` / `nvim-treesitter` (decided: manual step).
- Do not rename any plugin file or restructure directories beyond what's needed for the new spec contract.
- Do not change any plugin's options, keymaps, or visuals.

## Decisions

### 1. Per-file contract: each `lua/plugins/*.lua` returns `{ src, version, name?, setup? }`
Each plugin file keeps returning one table, but the table's shape changes: `src` (git URL), optional `version` (tag/branch/commit), optional `name` (local dir override), and optional `setup` (a function that does whatever the old `config`/`opts` pair did - typically `require("plugin").setup(opts)` plus any extra `vim.keymap.set`/autocmd calls).

Example (`gruvbox.lua`):
```lua
return {
    src = "https://github.com/morhetz/gruvbox",
    setup = function()
        vim.cmd("colorscheme gruvbox")
        local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
        vim.api.nvim_set_hl(0, "SignColumn", { bg = normal_bg })
    end,
}
```
**Alternative considered**: split each plugin into two files (a spec file and a setup file). Rejected - doubles the file count for no benefit at this scale (17 plugins) and makes the diff harder to review.

**Alternative considered**: inline everything in `init.lua` as one big `vim.pack.add` call with setup logic mixed in. Rejected - loses the current one-file-per-plugin organization the user already has and likes, and turns `init.lua` into an unmaintainable wall of config.

### 2. `init.lua` declares an explicit, ordered plugin list (no directory auto-scan)
`lazy.nvim`'s `spec = { { import = "plugins" } }` auto-discovered every file in the directory; `vim.pack` has no such mechanism, and more importantly it also had no ordering concept beyond `priority`/`dependencies`, both gone now. `init.lua` will hold an explicit ordered Lua list of module names (e.g. `{ "gruvbox", "plenary", "nvim-treesitter", ..., "which-key" }`), `require` each under `plugins.<name>`, collect every `src`/`version`/`name` into one `vim.pack.add({...})` call, then call each module's `setup()` in list order.

Order matters for exactly one case today: `gruvbox` must run its `setup()` (which sets the colorscheme and a derived highlight group) before anything that reads highlight groups at setup time. It is listed first. Everything else in the current config has no inter-plugin setup-order dependency (e.g. `lualine`'s gruvbox theme is a static Lua table from `lualine.themes.gruvbox`, not a runtime highlight read), so remaining order is kept close to the existing file listing for minimal diff review.

**Alternative considered**: auto-scan the `plugins/` directory (`vim.fn.readdir`) like today, with an optional per-file `priority` field to sort by. Rejected - rebuilding a priority-sort mechanism to replace the one feature (`dependencies`/`priority`) `vim.pack` intentionally omits adds complexity disproportionate to a 17-plugin personal config; an explicit list is one line to edit when adding a plugin and is easier to reason about than reconstructing ordering semantics.

### 3. Drop semver-range versions; pin explicit tags where a version constraint exists
`blink.cmp` currently pins `version = "1.*"` and `LuaSnip` pins `version = "v2.*"` - both are `lazy.nvim`-resolved semver ranges matched against git tags. `vim.pack`'s `version` field only accepts a literal tag, branch, or commit, not a glob/range. These two specs will pin the latest matching tag available at migration time (e.g. `v1.6.0`-style exact tag) instead of a range.

**Trade-off** (accepted): the config no longer auto-tracks "latest 1.x" on `vim.pack.update()` - bumping to a newer tag within the same major version now requires manually editing the pinned tag in the plugin file. This is consistent with the user's own "manual step over automation" preference already applied to build hooks.

### 4. No lockfile; version pins live directly in each plugin spec
`lazy.nvim` wrote a `lazy-lock.json` recording resolved commits for every plugin, giving reproducible installs across machines independent of what each spec file requested. `vim.pack` has no lockfile. Reproducibility instead comes only from whatever `version` each plugin's spec table pins explicitly; plugins with no `version` field track their default branch and can drift between machines/installs.

**Alternative considered**: hand-roll a lockfile (write resolved commits to a JSON file, read it back to pass as `version` on `vim.pack.add`). Rejected as out of scope - no existing requirement calls for cross-machine reproducibility beyond what's already pinned per-plugin, and building a lockfile mechanism is disproportionate to this migration's purpose.

## Risks / Trade-offs

- **[Risk]** Dropping lazy-loading means every plugin's Lua module is `require`'d and its `setup()` runs on every startup, including ones previously deferred until first use (`fzf-lua`, `vim-mundo`, etc.) → **Mitigation**: plugin count is modest (17); if startup time regresses noticeably after migration, `:Lazy profile`-equivalent manual timing (`nvim --startuptime`) can identify the worst offender for a future follow-up change.
- **[Risk]** Losing `lazy.nvim`'s `dependencies` field means nothing enforces that a dependency (e.g. `plenary.nvim` for `harpoon`) is fetched before the dependent's `setup()` runs → **Mitigation**: `vim.pack.add` is called once with the full plugin list before any `setup()` runs, so every plugin's code is already on the runtimepath by the time any `setup()` executes, regardless of list order. Only *within-setup* ordering (item 1 in Decisions) is a real risk, and only `gruvbox` currently needs it.
- **[Risk]** Pinned-tag versions (`blink.cmp`, `LuaSnip`) go stale silently since nothing flags "a newer 1.x tag exists" the way a semver range would resolve automatically → **Mitigation**: accepted trade-off per the user's manual-step preference; revisit only if it becomes a real annoyance.
- **[Risk]** `vim.pack` requires a sufficiently recent Neovim (0.12+); this config becomes incompatible with older Neovim installs that worked fine under `lazy.nvim` → **Mitigation**: none planned; the user has already decided to adopt `vim.pack`, implicitly accepting the version floor.

## Migration Plan

1. Rewrite each `lua/plugins/*.lua` file to the new `{ src, version?, name?, setup? }` contract, preserving every existing option/keymap/autocmd inside `setup`.
2. Rewrite `init.lua`: remove the `lazy.nvim` bootstrap block and `require("lazy").setup(...)` call; add the explicit ordered plugin-name list, the loop that builds specs and calls `vim.pack.add`, and the loop that calls each module's `setup()`.
3. Delete any now-unused `lazy.nvim` state the user wants cleaned up (e.g. the `lazy-lock.json` file and the cloned `lazy.nvim` data directory) - manual, outside version control, not part of this change's file diff.
4. Manually verify: delete (or rename aside) the local `lazy`/plugin data directories, start Neovim fresh, confirm all plugins install and every keybinding/colorscheme/statusline behaves as before.
5. Manually run the two documented build steps once (`cargo build --release` for `blink.cmp`, `:TSUpdate` for `nvim-treesitter`) and confirm completion/insertion-mode completion and syntax highlighting work.

**Rollback**: revert the commit(s) for this change; `lazy.nvim` re-bootstraps itself from its existing bootstrap block on next startup since nothing about its own cached install is deleted by rollback.
