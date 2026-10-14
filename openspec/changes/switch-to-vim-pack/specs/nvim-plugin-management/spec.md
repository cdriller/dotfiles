## Purpose

Defines how this Neovim configuration installs, loads, and keeps up to date all editor plugins, using Neovim's built-in package manager instead of a third-party plugin manager.

## ADDED Requirements

### Requirement: Built-in plugin manager only
Neovim SHALL install, load, and manage every configured plugin using only Neovim's built-in package manager. No third-party plugin manager (such as `lazy.nvim`) SHALL be downloaded, bootstrapped, or required for the configuration to start or for plugins to function.

#### Scenario: No third-party bootstrap on startup
- **WHEN** Neovim starts with this configuration
- **THEN** no third-party plugin manager is cloned, downloaded, or loaded, and no error occurs due to a missing third-party plugin manager

### Requirement: Missing plugins install automatically
WHEN a configured plugin is not yet present on disk, Neovim SHALL fetch and install it automatically during startup, without requiring a separate manual install command before the plugin becomes usable.

#### Scenario: First run on a machine with no plugins installed
- **WHEN** a user opens Neovim with this configuration on a machine where none of the configured plugins have been installed yet
- **THEN** Neovim fetches and installs all configured plugins as part of starting up, and they are available for use once startup completes

### Requirement: All plugins load eagerly at startup
Every configured plugin SHALL be loaded during Neovim startup. The configuration SHALL NOT defer loading a plugin until a later event, command invocation, filetype, or keymap press.

#### Scenario: Plugin functionality available immediately after startup
- **WHEN** Neovim finishes starting
- **THEN** every configured plugin's commands, keymaps, and autocommands are already registered and usable, without first needing to trigger a command, open a specific filetype, or press a lazy-load keymap

### Requirement: Explicit version pinning per plugin
For any plugin configured with a specific version constraint (tag, branch, or commit), Neovim SHALL install and update that plugin to exactly the configured version. Plugins with no version constraint SHALL track their default branch.

#### Scenario: Installing a plugin pinned to a version
- **WHEN** a plugin is configured with a specific version, branch, or tag
- **THEN** installing or updating that plugin results in exactly that version being checked out, not an unrelated newer or older revision

### Requirement: No automatic build-command execution
Neovim SHALL NOT automatically execute a plugin's post-install or post-update build command (e.g. a compiler invocation or a parser-update command). Where a plugin requires a build step to produce a working artifact, that step SHALL be documented as a manual action the user performs separately.

#### Scenario: Installing a plugin that requires a compiled artifact
- **WHEN** a plugin that requires a build step (such as compiling a native binary) is installed or updated
- **THEN** Neovim does not run the build command automatically, and the configuration's documentation states the manual command the user must run to produce the artifact

### Requirement: Existing plugin behavior and keybindings preserved
Aside from the change from lazy-loading to eager loading, every plugin's configured options, keybindings, autocommands, and visual appearance (colorscheme, statusline, etc.) SHALL remain behaviorally equivalent to the configuration prior to this migration.

#### Scenario: Keybinding still works after migration
- **WHEN** a user invokes a keybinding that was defined by a plugin before this migration (e.g. toggling the undo tree, navigating to a harpoon mark, triggering fuzzy grep)
- **THEN** the keybinding performs the same action as it did before the migration
