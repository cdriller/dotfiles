## Why

The Emacs config now has enough `C-c`-prefixed bindings that individual letters are hard to remember, and two related but distinct concepts are conflated: (1) concrete note/link *locations* ("nodes") that you open or link to, and (2) *aggregated views* that pull information together across multiple locations (deadlines, someday "waiting for" list, etc.). The existing `prilepp/find-entity` (`C-c o`) already provides a unified open/insert/copy picker across most node types, but under a mnemonic ("o" = "find entity") that doesn't match the "nodes" concept, while a separate, redundant set of single-purpose insert-only bindings still lives under `C-c i`. Consolidating everything node-related under one memorable `C-c n` binding, and letting `C-c v` remain the home for aggregated views, removes the duplication and makes the bindings self-describing.

## What Changes

- **BREAKING**: Rename `C-c o` (`prilepp/find-entity`) to `C-c n`. Behavior is unchanged: RET opens/jumps to the selected node, `C-i` inserts an org link to it at point, `C-c` copies that link to the clipboard/kill-ring.
- Add two new sources to the picker: **Someday** (the single `someday.org` file, treated as one candidate) and **Heading** (arbitrary org headings across `org-refile-targets`, replacing `my/insert-link-to-org-heading`).
- **BREAKING**: Remove the old single-purpose, insert-only bindings that are now redundant with the `C-c n` picker's `C-i` action: `C-c i z`, `C-c i l`, `C-c i j`, `C-c i a`, `C-c i i`, `C-c i g`, `C-c i v`, `C-c i p`, `C-c i h`, and the standalone `C-c s` (someday). `C-c i` is no longer bound.
- Update the which-key label for this binding from "find entity" to a "nodes"-oriented description.
- No changes to the existing `C-c v` ("view") group in this change; it remains the designated place for future aggregation views (e.g. a future "waiting for" view), documented as such but not implemented here.

## Capabilities

### New Capabilities
- `emacs-keybindings`: The unified `C-c n` node picker (open/insert/copy across all node types) and the `C-c v` view group, with which-key labeling and removal of now-redundant single-purpose node bindings.

### Modified Capabilities
(none — no pre-existing spec covers Emacs keybindings)

## Impact

- Affected files: `emacs/.config/emacs/lisp/init-find-entity.el` (rebind `C-c o`→`C-c n`, add Someday and Heading sources, update which-key label), `init-org.el` (remove `C-c i z`, `C-c i l`), `init-projects.el` (remove `C-c i j/a/i/g/v`), `init-contacts.el` (remove `C-c i p`), `init-files.el` (remove `C-c s`, remove `C-c i h` and `my/insert-link-to-org-heading` in favor of the new Heading source).
- User-facing impact: muscle memory for `C-c o`, `C-c i ...`, and `C-c s` must be relearned as `C-c n` (with RET/C-i/C-c actions on the picker).
- No new packages; reuses the existing `consult--multi` + vertico infrastructure already used by `prilepp/find-entity`.
