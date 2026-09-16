## Context

`nvim/.config/nvim/lua/lsp.lua` already calls `lsp.enable("jdtls")` with no
inline config, via the same `load_lsps` helper used for `vtsls` and
`solidity_custom` (see proposal.md - Why). Those two already moved to
self-contained files under `nvim/.config/nvim/lsp/`, which Neovim picks up
automatically because the config directory (and any plugin added to
`runtimepath`, which is currently how `nvim-lspconfig`'s bundled
`lsp/jdtls.lua` gets found) is scanned for `lsp/<name>.lua`. jdtls is the
one server in this config still falling through to that plugin-provided
default instead of an owned file.

jdtls is also the one server here with a real installation wrinkle: it
ships as an Eclipse/OSGi app (equinox launcher jar + OS-specific config
directory), and needs a `-data <dir>` argument pointing at a
project-specific workspace, or it will reuse/corrupt state across
unrelated Java projects. Every other server in this config is invoked as
a plain command name already present on `PATH`, installed outside the
dotfiles repo (no Brewfile or install script tracks these); none go
through `mason.nvim` for the actual binary.

Homebrew ships a `jdtls` formula (`brew install jdtls`, bottled, depends
on `openjdk`) that wraps the launcher-jar/config-dir resolution the same
way `mason.nvim`'s package does, without adding `mason.nvim` as the
mechanism.

## Goals / Non-Goals

**Goals:**
- A `jdtls` entry that behaves like `vtsls`/`solidity_custom`: fully
  defined by one file under `nvim/.config/nvim/lsp/`.
- Correct per-project workspace isolation (the one part install-time
  wrapping does *not* solve for you).
- Zero new Neovim plugins, zero `mason.nvim` involvement for jdtls.

**Non-Goals:**
- `nvim-jdtls` plugin features: DAP debugging, JUnit test runner,
  Java-specific refactor code actions (extract variable/method, generate
  constructor, etc.). These require bundling extra jars and a richer
  plugin; out of scope for a minimal LSP-only setup.
- Multi-JDK runtime mapping (`settings.java.configuration.runtimes`) for
  projects targeting an older Java version than jdtls itself runs on.
  jdtls' own default toolchain inference (from Gradle/Maven) is assumed
  sufficient for now.
- Workspace directory cleanup/eviction policy.
- Removing `mason.nvim` from the repo, or migrating any other server off
  it — scope is jdtls only.

## Decisions

**Install via Homebrew, not `mason.nvim`, not a hand-vendored tarball.**
- vs. `mason.nvim`: user explicitly wants this server off Mason, and
  every other server here is already a bare `PATH` binary, not a
  Mason-managed one — Homebrew keeps jdtls consistent with that
  convention instead of being the only Mason-managed exception.
- vs. manually downloading the jdtls tarball into the dotfiles repo: the
  equinox launcher jar's filename is version-specific
  (`org.eclipse.equinox.launcher_1.x.x.vYYYYMMDD-HHMM.jar`) and the
  correct OS config directory (`config_mac_arm` / `config_linux` / ...)
  has to be selected by hand; both would need to be re-discovered on
  every jdtls upgrade. The Homebrew formula wraps this exactly the way
  `mason.nvim`'s package does, and also pulls in `openjdk` as a
  dependency automatically (jdtls needs a modern JDK to run itself,
  independent of whatever JDK a given project targets).

**Own `lsp/jdtls.lua`, referencing the plain `jdtls` command from
`PATH`.**
- Matches `lsp/vtsls.lua`'s shape: a single file returning a
  `vim.lsp.Config` table, discovered automatically once
  `nvim/.config/nvim/lsp/` is on `runtimepath` (already true — it's the
  config dir).
- `root_dir` resolved via `vim.fs.root(bufnr, markers)` with markers
  `{ "pom.xml", "build.gradle", "build.gradle.kts", "gradlew", "mvnw",
  ".git" }`, same idiom `vtsls.lua` already uses for its own root
  resolution.
- `cmd` is built as a function (not a static list) so it can append
  `-data <workspace-dir>` per invocation: `workspace-dir` is derived by
  hashing the full resolved `root_dir` (e.g.
  `vim.fn.sha256(root_dir):sub(1, 12)`) into a subdirectory under
  `vim.fn.stdpath("cache") .. "/jdtls-workspace/"`. Hashing the full path
  (not just the project's folder basename) avoids collisions between
  different projects that happen to share a directory name.

**Keep `{ name = "jdtls" }` in `lua/lsp.lua`'s `load_lsps` list
unchanged.** It already does the right thing (`lsp.config["jdtls"] =
{}`, `lsp.enable("jdtls")`) once a same-named file exists under
`lsp/`; no code change needed there, only the new file.

## Risks / Trade-offs

- **Homebrew formula version drifts independently, no pin.** → Same
  exposure every other brew-installed server here already has (clangd,
  lua-language-server, pyright, ...); acceptable by existing convention.
  Can `brew pin jdtls` later if a specific version needs to be held.
- **No JDK-runtime mapping for older-Java projects.** → If a project
  targets a Java version jdtls can't infer correctly, completion/compile
  diagnostics for that project may be degraded. Deferred: add
  `settings.java.configuration.runtimes` to `lsp/jdtls.lua` if/when a
  real project needs it.
- **Workspace directories accumulate under `stdpath("cache")` forever.**
  → Low cost (index data, not large), manual `rm -rf` if it ever matters;
  no automatic eviction built.
- **No `nvim-jdtls` extras.** → Organize-imports-on-save, code lenses for
  test running, and refactor actions common in fuller Java setups won't
  be available. Matches the "very minimal" goal; revisit as a separate
  change if it becomes a real friction point.

## Migration Plan

1. `brew install jdtls` (one-time, outside the dotfiles repo, same as
   any other LSP binary here).
2. Add `nvim/.config/nvim/lsp/jdtls.lua`.
3. Restart Neovim, open a `.java` file inside a project with a build
   root marker, confirm the client attaches (`:LspInfo`) and
   diagnostics/completion/hover work.
4. Open a second, unrelated Java project and confirm its workspace/index
   data is separate (no crossed diagnostics, no stale symbols from the
   first project).

**Rollback:** delete `lsp/jdtls.lua` (falls back to whatever default is
on `runtimepath`, i.e. today's behavior) or remove the `{ name = "jdtls"
}` entry from `load_lsps` to disable Java LSP entirely.
