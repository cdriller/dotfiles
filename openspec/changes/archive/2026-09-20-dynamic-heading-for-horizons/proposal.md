## Why

The `C-c n` picker and the per-type pickers list every horizon entry (Action, Project, Area, Goal, Vision, Life) by its *filename* (`Get Independent of Apple Services`, `build`, ...). org-roam notes (Zettel/Literature) in the same picker show their `#+title:` instead, so the two kinds of entries behave inconsistently and a horizon's filename has to double as its human-readable name (with filesystem-driven constraints on characters and length). Horizon files should be searchable and readable by the title stored inside the file, exactly like org-roam nodes, with the filename remaining only the stable storage key.

## What Changes

- Every picker that lists horizon entries shows each entry's title (the file's `#+title:` keyword, read the way org-roam reads it) instead of its filename. This covers: the Action/Project/Area/Goal/Vision/Life sources of `C-c n` (`prilepp/find-entity`) and of `prilepp/read-entity-link`, the per-type `*-find` commands, the per-type `*-insert-*-link` commands and their `org-insert-link` completion, the archive/restore commands (`C-c a a` / `C-c a r`), and `prilepp/action-move-to-context`.
- When a file has no `#+title:` keyword, its entry falls back to the filename (without `.org`), so nothing breaks for the existing files, none of which currently carries a `#+title:`.
- When two entries of the same type resolve to the same title, the candidates are disambiguated so each stays individually selectable.
- Selecting an entry still resolves to the same file; org links (`[[project:NAME]]`, `[[file:...]]`) keep using the filename as the link target, while the link *description* inserted/copied by the picker becomes the title.
- Newly created horizon files (via any of the six types' ensure-file/creation paths) are seeded with `#+title: <name>` as their first line, so new entries have a title from the start.
- Archived entries are labelled with their title too (still ordered after active ones and still annotated "(archiviert)").

Out of scope: adding `#+title:` lines to the existing horizon files (a one-off content migration the user can do by hand or ask for separately), renaming files when a title changes, the non-horizon sources (Zettel, Literature, Person, Routine, Someday, Agenda, Heading), and the dashboard.

## Capabilities

### New Capabilities
- `emacs-horizon-titles`: horizon entries are identified to the user by the `#+title:` stored in their file (with filename fallback and duplicate disambiguation) in every picker that lists them, and new horizon files are created with a `#+title:` line.

### Modified Capabilities
- `emacs-keybindings`: the "Unified node picker" requirement currently says the Action/Project/Area/Goal/Vision/Life candidates behave unchanged (filename-based); their candidate labels and inserted/copied link descriptions become title-based.

## Impact

- `emacs/.config/emacs/lisp/init-horizon-types.el`: new title-reading/caching helper and a name↔title candidate helper; `prilepp/define-horizon-type` seeds `#+title:` in new files and the generated `*-find`/`*-insert-*-link` functions use title candidates.
- `emacs/.config/emacs/lisp/init-find-entity.el`: the six horizon sources in `prilepp/entity-sources` map displayed titles back to entry names.
- `emacs/.config/emacs/lisp/init-horizon-archive.el`: `prilepp/archive-entry`, `prilepp/restore-entry` and `prilepp/horizon-archived-names` consumers use title candidates. Note: this file currently has uncommitted changes in the main working copy (`prilepp/horizon-archived-names` / `prilepp/ensure-file--check-archive` active-over-archive precedence) that this change builds on; commit them before applying this change.
- `emacs/.config/emacs/lisp/init-files.el`: `prilepp/action-move-to-context` uses title candidates.
- No new dependencies, no change to on-disk file names, link targets, or existing note contents.
