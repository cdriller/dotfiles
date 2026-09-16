## 1. Install jdtls

- [x] 1.1 Run `brew install jdtls` and verify `command -v jdtls` resolves
  to the Homebrew-installed binary
- [x] 1.2 Verify `java -version` (pulled in via the `openjdk` dependency)
  reports a version recent enough to run jdtls

## 2. Add the native lsp/jdtls.lua config

- [x] 2.1 Create `nvim/.config/nvim/lsp/jdtls.lua` with `filetypes = {
  "java" }`, `root_dir` resolved via `vim.fs.root` against `{ "pom.xml",
  "build.gradle", "build.gradle.kts", "gradlew", "mvnw", ".git" }`
  (mirroring `lsp/vtsls.lua`'s `root_dir` shape), and verify the file
  loads without Lua errors (`:luafile` or `:checkhealth lsp`)
- [x] 2.2 Implement the per-project workspace `-data` directory: hash the
  resolved `root_dir` (e.g. `vim.fn.sha256(root_dir):sub(1, 12)`) into
  `vim.fn.stdpath("cache") .. "/jdtls-workspace/<hash>"`, appended to
  `cmd`, and verify two different project roots produce two different
  workspace directories on disk

## 3. Verify end-to-end behavior

- [x] 3.1 Open a `.java` file inside a project with a recognized root
  marker, run `:LspInfo`, and verify a `jdtls` client is attached with
  the expected `root_dir`
- [x] 3.2 Verify diagnostics, completion, hover, and go-to-definition work
  in that buffer (e.g. trigger a known compile error, request hover on a
  known symbol)
- [x] 3.3 Open a Java file from a second, unrelated project and verify
  (via `:LspInfo` or the workspace directories from 2.2) that it gets its
  own isolated workspace/index data, with no diagnostics or symbols
  leaking from the first project
- [x] 3.4 Reopen a Java file from the first project and verify it reuses
  its own prior workspace directory rather than a fresh or unrelated one
