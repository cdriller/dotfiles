## Context

See `proposal.md` - Why. Relevant current state:

- `init-horizon-types.el` defines the macro `prilepp/define-horizon-type` and the registry `prilepp/horizon-types`, plus generic helpers built on it (entry listing/title lookup/label de-duplication).
- Six concrete declarations use that macro: `proj`, `aor`, `life`, `goals`, `vision` in `init-projects.el`; `actions` in `init-files.el`. `init-projects.el` also has unrelated Routine code (`prilepp/routine-*`), and `init-files.el` also has unrelated quick-open commands (`my/edit-init-file`, journal) plus Actions-specific commands (`prilepp/agenda-deadlines`, `prilepp/action-move-to-context`) and the unrelated `heading:` link type.
- `agendas` (directory `~/notes/agendas/`) hand-duplicates the macro's list/ensure/find shape in `init-files.el` instead of using it, so it is not in `prilepp/horizon-types` and gets none of the archive/title behavior the registered types get.
- `init-horizon-archive.el` (archive/restore, path mirroring, stale-link fallback, `org-archive-location` redirect) iterates `prilepp/horizon-types`, so it already works for any *registered* type without modification.
- `init-find-entity.el`'s `prilepp/entity-sources` builds six of its `C-c n` sources generically via `prilepp/entity-sources--horizon` (one per registered type) but hand-writes the Agenda source separately, duplicating that shape too.
- `prilepp/slugify` is defined in `init-contacts.el` and called from `init-projects.el` (Routines), with no `require` declaring that dependency - it works only because `init.el`'s load order happens to load contacts... actually loads it *after* projects (`init-projects` at position 8, `init-contacts` at position 10), so this currently relies on `prilepp/slugify` only being called interactively, never at load time.

## Goals / Non-Goals

**Goals:**
- One file holds all seven GTD list-type declarations (Action, Project, Area, Goal, Vision, Life, Agenda), so the full set is visible at a glance.
- `agendas` uses the macro like every other type, with no hand-written list/ensure/find duplication left.
- The "horizon type" vocabulary in code (macro, registry, generic helpers, file names) becomes "GTD list type", matching that it now covers a type (Agenda) that isn't a GTD "horizon of focus".
- Cross-module utility functions (starting with `prilepp/slugify`) live in one file with explicit `require`s at every call site, not implicit load-order dependencies.

**Non-Goals:**
- No change to on-disk directory names (`~/notes/horizons/...`, `~/notes/agendas/`) or to any existing `.org` file's content.
- No change to the per-type generated API surface: `prilepp/proj-directory`, `prilepp/actions-ensure-file`, `prilepp/org-insert-project-link`, etc. keep their exact current names. Only the macro itself and the shared generic helpers around it are renamed - this keeps the rename's blast radius to the ~12 generic symbols in `init-horizon-types.el`/`init-horizon-archive.el`/`init-find-entity.el`, not the ~40 per-type symbols the macro expands to.
- No change to the `my/` vs `prilepp/` naming split noted during exploration - out of scope for this change.
- No new org link type for Agenda (`:link-word` stays `nil`, matching its current file-link-only behavior).
- No renaming of the OpenSpec capability paths `emacs-horizon-archive` / `emacs-horizon-titles` (existing capability paths are preserved; only their delta requirement text is extended to cover Agenda).
- Does not address the German/English mix in user-facing strings, or the `citar-bibliography` vs `org-cite-global-bibliography` path mismatch noted during exploration - unrelated to this change.

## Decisions

### File layout

| File (after) | Replaces / origin | Contents |
|---|---|---|
| `init-utils.el` (new) | — | `prilepp/slugify`; any other function with call sites in more than one existing domain file, found by grepping for cross-file references during implementation |
| `init-gtd-list-types.el` | renamed from `init-horizon-types.el` | `prilepp/define-gtd-list-type` macro, `prilepp/gtd-list-types` registry, generic entry/title/label helpers |
| `init-gtd-lists.el` (new) | merges the list-type declarations out of `init-projects.el` and `init-files.el` | All seven `prilepp/define-gtd-list-type` calls (Action, Project, Area, Goal, Vision, Life, Agenda); the Actions-specific `org-agenda-custom-commands`/`prilepp/agenda-deadlines`/`prilepp/action-move-to-context` move here too, since they're coupled to the Actions declaration, not to quick-open |
| `init-files.el` | slimmed down | `my/edit-init-file`, `my/edit-someday-file`, journal (`prilepp/journal-*`), `prilepp/org-heading-complete` + `heading:` link registration; Commentary header updated to drop the now-moved material |
| `init-routines.el` | renamed from `init-projects.el` | Only `prilepp/routine-*` remains once the five declarations move out |
| `init-gtd-list-archive.el` | renamed from `init-horizon-archive.el` | Same logic, updated to the renamed macro/registry/helpers; Commentary's "loaded after init-projects/init-files" simplifies to "loaded after init-gtd-lists" (was two dependencies, now one) |
| `init-contacts.el`, `init-calendar.el`, `init-org.el`, `init-dashboard.el`, `init-completion.el`, `init-basics.el`, `init-packages.el`, `init-paths.el` | unchanged | — |

`init-find-entity.el` is not renamed (its own name doesn't mention "horizon"), but its Commentary, `require`s, and the `prilepp/entity-sources--horizon` helper (and its Agenda call site) are updated - see below.

### Symbol renames (generic layer only)

Every symbol whose name contains "horizon" and that lives in the generic layer (not a per-type generated symbol) is renamed by replacing "horizon" with "gtd-list", e.g. `prilepp/horizon-types` → `prilepp/gtd-list-types`, `prilepp/define-horizon-type` → `prilepp/define-gtd-list-type`, `prilepp/horizon-entries` → `prilepp/gtd-list-entries`, `prilepp/horizon-file-title` → `prilepp/gtd-list-file-title`, `prilepp/horizon-archived-entries`/`-names` → `prilepp/gtd-list-archived-entries`/`-names`, `prilepp/horizon-archive-location--maybe-set` → `prilepp/gtd-list-archive-location--maybe-set`, and `prilepp/entity-sources--horizon` → `prilepp/entity-sources--gtd-list`. Symbols that already have a generic, type-agnostic name without "horizon" in it (`prilepp/archive-entry`, `prilepp/restore-entry`, `prilepp/archive-path`, `prilepp/notes-root`, ...) are untouched. `my/org-horizon-files` (in `init-org.el`) is **not** renamed: it names the on-disk `~/notes/horizons/` directory it walks for refile targets, not the code concept, and that directory name is a Non-Goal to change.

### Agenda's macro declaration

```elisp
(prilepp/define-gtd-list-type agendas
  :directory "~/notes/agendas/"
  :list-fn prilepp/agendas--list-entries
  :find-fn prilepp/agendas-find
  :find-prompt "Agenda: "
  :ensure-fn prilepp/agendas-ensure-file
  :default-content nil
  :link-word nil)
```

Same directory and function names it already has today (`prilepp/agendas-directory`, `-ensure-file`, `-find`), so every existing call site (`init-find-entity.el`'s Routine-independent uses, `prilepp/agendas--list-entries`) keeps working unchanged; only their definitions move from hand-written to macro-generated. One observable difference: newly-created agenda files now start with `#+title: NAME` (the macro always seeds that), where the hand-written `prilepp/agendas-ensure-file` previously wrote an empty file. Existing agenda files without a title are unaffected and keep showing by filename (the existing, unmodified filename-fallback requirement already covers this).

`init-find-entity.el`'s hand-written Agenda source block is replaced with `(prilepp/entity-sources--gtd-list "Agenda" ?a 'agendas)`, identical in shape to the other six sources, once Agenda is registered.

### `init.el` load order

```
init-paths → init-packages → init-basics → init-completion → init-org
  → init-utils
  → init-gtd-list-types
  → init-gtd-lists
  → init-files
  → init-routines
  → init-gtd-list-archive
  → init-contacts → init-calendar → init-find-entity → init-dashboard
```

`init-utils` moves early (position 6) since it's a leaf dependency other modules call into. `init-gtd-list-archive` keeps its existing constraint of loading after every list-type declaration exists, now satisfied by one file (`init-gtd-lists`) instead of two.

### Explicit `require`s replace implicit load-order dependencies

`init-routines.el` gets `(require 'init-utils)` at its top (for `prilepp/slugify`), matching the existing pattern in `init-find-entity.el` (`(require 'init-horizon-types)` → `(require 'init-gtd-list-types)`) and `init-gtd-list-archive.el`. This is called out specifically because it's the one dependency in this change that previously worked only by accident of load order.

## Risks / Trade-offs

- **Missed rename leaves a stale reference** (e.g. a call site still using `prilepp/horizon-entries`) → Would fail loudly at startup (`void-function`/`void-variable`) rather than silently misbehaving, since Elisp resolves these at load/call time. Mitigation: after renaming, grep the whole `lisp/` directory for the literal string `"horizon"` and confirm every remaining hit is either `my/org-horizon-files` (intentionally unchanged) or a `~/notes/horizons/` path string (data, not code identifier) - not a symbol name.
- **Merging `init-gtd-lists.el` changes `init.el`'s require order**, which could reorder side effects (e.g. `which-key-add-key-based-replacements` calls) → None of the moved declarations have side effects that depend on relative order with unrelated modules (they only depend on `init-gtd-list-types` being loaded first, which the new order preserves); moving `prilepp/agenda-deadlines`'s `org-agenda-custom-commands` setq into the merged file doesn't change when it runs relative to `init-dashboard.el`, which is still loaded after.
- **Agenda joining the archive registry is a real behavior change** (per proposal) → Already called out as such in the proposal and covered by the spec deltas; not a hidden side effect of this refactor.

## Migration Plan

Pure local file/require changes in one machine's dotfiles checkout; no build step, service, or external dependency. Apply by editing the files as designed, then start Emacs (or `M-x eval-buffer` on `init.el`) to confirm it loads without `void-function`/`void-variable` errors and that `C-c n` narrowed to Agenda still lists existing agendas. Rollback is `git revert` / restoring the previous file set - no data migration to undo, since no `~/notes/` content is touched.
