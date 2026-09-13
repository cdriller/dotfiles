## Why

`emacs/.config/emacs/lisp/init-projects.el` defines five near-identical "horizon type" implementations (Project, Area, Life, Goal, Vision), each hand-copied with the same five-function shape: a `*-directory` variable, a `*--list-*` completion helper, a `*-ensure-file` find-or-create function, an `org-*-follow`/`org-*-complete` link handler pair, and an `*-insert-*-link` command — roughly 230 lines of duplicated boilerplate. `init-files.el` implements the sixth type (Actions/contexts) with the same shape again, slightly diverged (no dedicated link type, no insert-link command). A planned follow-up change will add archive support (moving/mirroring files under `~/notes/archive/...` and fixing a stale-link bug where following a link to an archived item silently recreates an empty file) to every one of these types. Doing that fix six times, once per hand-copied implementation, is error-prone and against the boilerplate-duplication principle. Consolidating the six implementations onto one shared definition mechanism now means the archive feature (and any future fix) can be implemented once and apply to all types uniformly.

## What Changes

- Introduce a single shared mechanism (e.g. a macro or factory function, decided in design.md) that generates the `*-directory` variable, `*-ensure-file`, `*--list-*`, `org-*-follow`/`org-*-complete` link handlers, and `*-find`/`*-insert-*-link` commands for a horizon type from a compact per-type declaration (name, directory, link type, optional default file content).
- Re-implement the five existing types in `init-projects.el` (Project, Area, Life, Goal, Vision) using the shared mechanism, replacing their hand-written duplicates.
- Re-implement the Actions/contexts type in `init-files.el` (`prilepp/actions-directory`, `prilepp/actions--list-contexts`, `prilepp/actions-ensure-file`, `prilepp/actions-find`) using the same shared mechanism, so all six horizon types are structurally consistent for the first time (Actions currently has no `org-actions-follow`/`-complete` link type or `*-insert-*-link` command — this change adds them for consistency, since the shared mechanism generates the full set uniformly).
- **No user-observable behavior change**: all existing keybindings, which-key labels, org link types (`project:`, `area:`, `life:`, `goal:`, `vision:`), completion candidates, file locations, and default file contents remain exactly as they are today. This is an internal refactor; the newly-added Actions link type (`action:`, if added — see design.md) is the only net-new capability, and it is additive/non-breaking (no code currently depends on its absence).
- Functions and variables consumed by other files (`prilepp/proj--list-projects`, `prilepp/proj-ensure-file`, `prilepp/aor--list-aors`, `prilepp/aor-ensure-file`, `prilepp/life--list-entries`, `prilepp/life-ensure-file`, `prilepp/goals--list-entries`, `prilepp/goals-ensure-file`, `prilepp/vision--list-entries`, `prilepp/vision-ensure-file`, `prilepp/actions--list-contexts`, `prilepp/actions-ensure-file`, and the `prilepp/routine--candidates` helper's use of `prilepp/aor-directory`) keep their exact existing names, so `init-find-entity.el` (`prilepp/entity-sources`) and `init-org.el` (`org-refile-targets`) require no changes.

## Capabilities

### New Capabilities
(none — this is a pure internal refactor with no spec-level behavior change; `skip_specs: true` is set in `.openspec.yaml`)

### Modified Capabilities
(none)

## Impact

- Affected files: `emacs/.config/emacs/lisp/init-projects.el` (five type definitions replaced by shared-mechanism calls), `emacs/.config/emacs/lisp/init-files.el` (Actions type replaced by a shared-mechanism call).
- Not affected: `init-find-entity.el`, `init-org.el`, `init-contacts.el`, `init-org.el`'s `org-refile-targets`, all existing keybindings and which-key labels, all `~/notes/horizons/**` file contents and locations.
- No new packages.
- This change is a prerequisite for a follow-up change (not yet proposed) that will add archive support for all horizon types.
