## Context

See proposal.md - Why for motivation and the specs (`emacs-horizon-titles`, delta on `emacs-keybindings`) for required behavior.

Current state (observed in `emacs/.config/emacs/lisp/`):

- `prilepp/define-horizon-type` (init-horizon-types.el) generates, per type, a `*--list-*` function returning **filenames without `.org`**. Those names are simultaneously the completion label, the key handed back to `*-ensure-file`, and the link target in `[[project:NAME]]`-style links.
- The `C-c n` sources in `prilepp/entity-sources` (init-find-entity.el) pass those names straight through as `:items`, and receive the same string in `:action`/`:new`/`:link`. Archived names (`prilepp/horizon-archived-names`, init-horizon-archive.el) are appended after the active ones and marked by `:annotate` via `member` on the same string.
- The macro also generates the per-type `*-find`, `*-insert-*-link` and `*-complete` (link completion) functions, all doing `completing-read` over `list-fn`; `prilepp/archive-entry`, `prilepp/restore-entry` and `prilepp/action-move-to-context` do the same.
- `prilepp/dashboard` (init-dashboard.el) also calls `prilepp/actions--list-contexts` / `prilepp/proj--list-projects` and needs filenames.
- None of the ~35 existing horizon files has a `#+title:` line today (actions files start with `#+TODO:`, project files with `#+TODO:` + `* TODO NAME`, the others with plain headings). Only the not-yet-existing new files created by the macro's ensure-fn would carry one.
- org-roam nodes (Zettel/Literature) get their titles from the org-roam DB, but the horizon directories are outside `org-roam-directory` (`~/notes/slipbox`).

## Goals / Non-Goals

**Goals:**
- One shared, cheap way to turn "a horizon type" into a list of `(label, name, title)` entries, used by every picker, so the label rule (title → filename fallback → disambiguation) lives in exactly one place.
- Filename stays the identity/key: no renames, no link-target changes, no changes to `*-ensure-file` semantics for existing entries.

**Non-Goals:**
- Backfilling `#+title:` into the existing files (see Migration Plan), renaming files on title change, indexing horizons into org-roam, changing the dashboard, or touching non-horizon sources.
- Full-text/heading search inside horizon files (this only concerns the entry label).

## Decisions

**1. Title = the `#+title:` keyword, read directly from the file head.**
A small function `prilepp/horizon-file-title (file)` reads the first 4 KiB with `insert-file-contents` into a temp buffer, restricts to the text before the first `^\*` heading, and matches `^#\+title:[ \t]*\(.+\)` case-insensitively; empty/absent → nil. Results are memoized in a hash table keyed by absolute path with the file's modification time as validity check, so re-opening `C-c n` re-reads only changed files (the "next time a picker opens" requirement without a file watcher).
Alternatives: (a) `org-collect-keywords` in a buffer - parses through org, but needs `find-file-noselect`/temp org buffer per file, slower and loads org mode 35+ times per picker; (b) org-roam's DB - would require moving/duplicating horizons into `org-roam-directory` or a second DB, far beyond this change; (c) title from the first heading - contradicts "wie bei org-roam" and the project files' `* TODO NAME` heading carries a TODO keyword. A plain regex is what `#+title:` handling in org-roam ultimately does, and the head-only scan matches where org-roam accepts keywords in practice.

**2. Keep `list-fn` (names) unchanged; add a separate entries function.**
`prilepp/horizon-entries (slug &optional include-archived)` (init-horizon-types.el; archived listing supplied by init-horizon-archive.el, which already owns archive paths) returns a list of `(LABEL NAME TITLE)`: `NAME` is the filename-without-extension, `TITLE` the read title or NAME, `LABEL` equals TITLE except that colliding labels get ` (NAME)` appended. Collision detection runs over active and archived entries together, because both live in one `consult--multi` candidate namespace. Active entries come first, archived entries after (preserving the existing ordering requirement).
Alternative: change `list-fn` to return labels. Rejected: the dashboard and `prilepp/horizon-archived-names` and `ensure-fn` all expect filenames, and changing the meaning of an existing function silently is error-prone.

**3. Map label back to name at action time, by lookup, not by string properties.**
Sources keep `:items` as label strings. `:action`/`:new`/`:link`/`:annotate` receive the selected label and resolve it via `(assoc label (prilepp/horizon-entries slug t))`. A miss means the user typed a brand-new name: use the typed text as both NAME and (via seeded `#+title:`) title. This mirrors how the Heading and Routine sources already resolve their candidate back through a recomputed alist, and avoids depending on Consult preserving text properties through its tofu handling. Cost is one extra cached scan per selection.
Alternative: `propertize` the name onto the label. Rejected as fragile against Consult/Vertico string handling.

**4. Links: target stays the filename, description becomes the title.**
`:link` for the horizon sources and the `*-insert-*-link` commands use NAME for the target and TITLE for the description. `*-follow` handlers are unchanged. `*-complete` (org-insert-link completion) completes over labels and returns `word:NAME`.

**5. New files get `#+title: NAME` from the macro.**
The generated ensure-fn writes `#+title: NAME\n` before the `default-content` (which may be nil, static or `%s`-interpolated) - done once in the macro so all six types, including Actions in init-files.el, change together. `#+TODO:` after `#+title:` is unaffected (org reads file-level keywords wherever they are in the header). No per-type `:default-content` needs editing.
Alternative: put `#+title:` into each type's `:default-content`. Rejected: six edits, and the `%s` interpolation supports only one substitution.

**5a. Only the pickers are switched, not every consumer of names.** Dashboard and internal callers keep using `list-fn`; the archive/restore commands and `prilepp/action-move-to-context` switch to entries because they present a picker to the user.

## Risks / Trade-offs

- **[No visible effect on current files]** No existing horizon file has a `#+title:`, so every entry falls back to its filename until titles are added → keep the fallback so nothing regresses, call this out to the user, and treat backfilling as follow-up (Migration Plan).
- **[Disambiguation string is unstable]** A label like `Backup (a)` changes if a colliding title is edited → labels are only used for the current selection, never stored; links use filenames.
- **[Typed name matches a title, not a filename]** Typing an existing title opens that entry instead of creating a new file with that name (same as org-roam behavior) → acceptable; a genuinely new name still creates `NAME.org`.
- **[Title beyond 4 KiB or after the first heading is ignored]** → documented; `#+title:` belongs in the file header, and newly created files put it on line 1.
- **[Depends on uncommitted work]** The main working copy has uncommitted edits to `init-horizon-archive.el` (`prilepp/horizon-archived-names` now excludes names that also exist actively; `prilepp/ensure-file--check-archive` prefers the active file). This change reads/extends the same functions and will conflict or misbehave if applied against a checkout without them → commit that work first (or apply this change on top of it).
- **[Performance]** Each picker open stats every horizon file and reads at most 4 KiB of changed ones; with tens of files this is imperceptible.

## Migration Plan

No data migration is needed for the change to work. Optional follow-up, not part of this change: add `#+title: <filename>` to the existing horizon files (e.g. a one-off command) so the new labels show up, then edit titles at will. Rollback is reverting the Elisp; files that gained a `#+title:` line stay valid org.

## Open Questions

- Should a later change offer a command to backfill `#+title:` into existing horizon files? (Deferrable - does not affect the specs, approach or tasks here.)
