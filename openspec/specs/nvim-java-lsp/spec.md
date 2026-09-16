# nvim-java-lsp Specification

## Purpose

Gives Java files in Neovim the same baseline LSP experience (diagnostics,
completion, hover, go-to-definition) already available for other
languages in this config, with correct per-project workspace isolation.

## Requirements

### Requirement: Java LSP Support
Neovim SHALL attach a Java language server to buffers with filetype
`java`, providing diagnostics, completion, hover, and go-to-definition
through the standard LSP client.

#### Scenario: Opening a Java file inside a recognized project root
- **WHEN** a user opens a `.java` file inside a directory tree containing
  a build root marker (`pom.xml`, `build.gradle`, `build.gradle.kts`, or
  `.git`)
- **THEN** Neovim attaches an LSP client to that buffer and diagnostics,
  completion, and hover become available without further manual setup

### Requirement: Per-Project Workspace Isolation
Each distinct Java project root SHALL get its own isolated language
server workspace/index data, so opening or switching between multiple
Java projects does not mix or corrupt one project's index state with
another's.

#### Scenario: Working across two Java projects in sequence
- **WHEN** a user opens a Java file from project A, then later opens a
  Java file from unrelated project B
- **THEN** project B's language server session uses workspace/index data
  distinct from project A's, and project A's diagnostics/index are left
  unaffected

#### Scenario: Reopening a previously used project
- **WHEN** a user reopens a Java file from a project root they worked in
  before
- **THEN** the language server reuses that project's own prior
  workspace/index data rather than starting from another project's data
