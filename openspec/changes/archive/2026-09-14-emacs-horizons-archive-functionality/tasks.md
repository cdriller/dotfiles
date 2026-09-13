## 1. Registry: extend `init-horizon-types.el`

- [x] 1.1 Add `(defvar prilepp/horizon-types nil ...)` and `prilepp/horizon-type--register` (upsert via `setf`/`alist-get`, keyed by slug) to `init-horizon-types.el`. Verify: evaluating the file twice leaves `(length prilepp/horizon-types)` unchanged at 6 after all six types below are (re-)defined, not growing.
- [x] 1.2 Extend `prilepp/define-horizon-type`'s expansion to call `prilepp/horizon-type--register` with a plist literal (`:slug`, `:directory-var`, `:list-fn`, `:ensure-fn`, `:find-fn`, `:link-word`) built from the macro's own arguments. Verify via `macroexpand-1` on an existing call (e.g. the `proj` one in `init-projects.el`) that the expansion includes this registration form with the correct literal values.
- [x] 1.3 After a full Emacs restart, verify `prilepp/horizon-types` has exactly 6 entries (`proj`, `aor`, `life`, `goals`, `vision`, `actions`) via `M-x ielm` + `(length prilepp/horizon-types)` and inspecting one entry's plist.

## 2. Path mirroring: `init-horizon-archive.el`

- [x] 2.1 Create `emacs/.config/emacs/lisp/init-horizon-archive.el` with header/Commentary and `(provide 'init-horizon-archive)`.
- [x] 2.2 Define `prilepp/notes-root`, `prilepp/archive-root`, `prilepp/archive-path`, and `prilepp/active-path` per design.md. Verify: `(prilepp/archive-path "~/notes/horizons/proj/Mail Server.org")` returns `"~/notes/archive/horizons/proj/Mail Server.org"`, and `(prilepp/active-path (prilepp/archive-path X))` equals `(expand-file-name X)` for a sample path.

## 3. Archive / restore commands

- [x] 3.1 Implement `prilepp/horizon-archived-names (slug)`: lists `.org` files (sans extension) directly under `(prilepp/archive-path directory-var-value)` for the given type's registry entry, returning `nil` if that directory doesn't exist (matching the existing `*--list-*` guard pattern). Verify manually against a directory you create by hand under `~/notes/archive/horizons/proj/`.
- [x] 3.2 Implement `(defun prilepp/archive-entry () (interactive) ...)`: `completing-read` over registered slugs/display names, then over that type's active entry names (via its `:list-fn`), compute the active path, move the file to `(prilepp/archive-path active-path)` (creating parent directories with `make-directory ... t`), save-then-move any open buffer for that file (redirecting it via `set-visited-file-name` rather than leaving it pointed at a deleted path), and call `(org-id-update-id-locations (list new-path))`. Verify: archiving an existing test project moves its file to the mirrored archive path with unchanged content, and an open buffer for it follows to the new path without a "file has changed on disk"/dangling-buffer warning.
- [x] 3.3 Implement `(defun prilepp/restore-entry () (interactive) ...)`: mirror image of 3.2, using `prilepp/horizon-archived-names` (3.1) to prompt for the archived entry name, moving it back via `prilepp/active-path`. Verify: restoring the project archived in 3.2 puts it back at its original active path with unchanged content, and `id:` links into it still resolve.
- [x] 3.4 Bind `C-c a a` to `prilepp/archive-entry` and `C-c a r` to `prilepp/restore-entry`; add a which-key label `"C-c a" "archive"`. Verify both keybindings invoke the correct command and which-key shows the "archive" group label on `C-c a`.

## 4. Stale-link fix

- [x] 4.1 Implement a named `prilepp/ensure-file--check-archive` advice function (per design.md, closing over each entry's `directory-var` via a per-entry wrapper, not an inline lambda) and a `dolist` over `prilepp/horizon-types` that `advice-add`s it `:around` on every registered `:ensure-fn`. Verify: `M-x describe-function` on `prilepp/proj-ensure-file` shows exactly one `:around` advice attached, even after re-evaluating this file.
- [x] 4.2 Verify the fix end-to-end: archive a test project (via `prilepp/archive-entry`), then follow an existing `[[project:<that name>]]` link (or call `(prilepp/proj-ensure-file "<that name>")` directly) and confirm it opens the archived file, and confirm no new empty file was created under the active `proj/` directory.
- [x] 4.3 Verify the non-archived case is unaffected: calling an `*-ensure-file` function with a name that exists neither actively nor archived still creates a new active file exactly as before (no regression from `emacs-refactor-horizon-setup`'s behavior).

## 5. `org-archive-location` redirect for heading-level archiving

- [x] 5.1 Implement the `find-file-hook` function that, for a buffer visiting a file under any registered type's `directory-var`, sets `org-archive-location` buffer-locally to `(concat (prilepp/archive-path buffer-file-name) "::")`, and add it to `find-file-hook`. Verify: opening a file under `~/notes/horizons/actions/` shows (via `C-h v org-archive-location`) the mirrored archive path as its buffer-local value; opening an unrelated Org file (e.g. a Zettel) shows Org's global default, unchanged.
- [x] 5.2 Verify `C-c C-x C-a` (`org-archive-subtree`) on a `DONE` heading in `~/notes/horizons/actions/org.org` moves that heading (with its properties, e.g. `ARCHIVE_TIME`/`ARCHIVE_OLPATH`, preserved as Org normally adds them) into `~/notes/archive/horizons/actions/org.org`, creating that file/its parent directories if they don't exist yet, and that the heading no longer appears in the active file.
- [x] 5.3 Verify `C-c C-x C-a` on a heading in a non-horizon file (e.g. a Zettel note) still archives to Org's default same-directory `_archive` location, unaffected by this change.

## 6. `C-c n` picker: low-priority archived candidates

- [x] 6.1 In `init-find-entity.el`, for each of the six horizon-type sources (Action, Project, Area, Goal, Vision, Life) in `prilepp/entity-sources`, change `:items` to `(append (<existing active list-fn>) (prilepp/horizon-archived-names '<slug>))`. Verify: with at least one archived and one active entry for a type, narrowing `C-c n` to that type's key shows the active entry(ies) first, archived entry(ies) after.
- [x] 6.2 Verify RET on an archived candidate opens the archived file (not a newly created active one), and `C-i`/`C-c` on an archived candidate insert/copy a link exactly as for an active entry (reusing the existing `:action`/`:link` closures unchanged, per design.md - these already call `*-ensure-file`, which now resolves archived names correctly per task 4).
- [x] 6.3 Verify the five non-horizon sources (Zettel, Literature, Person, Routine, Someday, Agenda, Heading) are unaffected: their candidate lists and behavior are identical to before this change.
- [x] 6.4 For each of the six horizon-type sources, hoist the archived-name list into a `let` shared by `:items` and a new `:annotate` function, `(lambda (n) (when (member n archived) (propertize " (archiviert)" 'face 'completions-annotations)))`. Verify: an archived candidate shows the "(archiviert)" annotation in the `C-c n` completion list; an active candidate shows none.
- [x] 6.5 Verify `:action`/`:new`/`:link` are unaffected by 6.4: RET/`C-i`/`C-c` on an annotated (archived) candidate still resolve and behave exactly as verified in 6.2, i.e. the annotation is display-only and never reaches `*-ensure-file`.

## 7. Load order

- [x] 7.1 In `emacs/.config/emacs/init.el`, add `(require 'init-horizon-archive)` after `(require 'init-projects)` and before `(require 'init-find-entity)`. Verify a full `emacs -Q`-free restart (or `emacs --batch -l init.el`) loads with no errors and no "void function"/"void variable" warnings related to `prilepp/horizon-types`, `prilepp/archive-path`, or the new commands.

## 8. Manual end-to-end verification

- [x] 8.1 Full restart; for a real (or disposable test) entry of each of the six types, run through: create active -> archive via `C-c a a` -> confirm it disappears from `C-c n`'s primary (active) position for that type and reappears at the bottom -> follow a link to it (or select it via `C-c n`) and confirm it opens the archived file -> restore via `C-c a r` -> confirm it's back in its original active position in `C-c n`.
- [x] 8.2 For `actions`: mark a heading `DONE`, archive it with `C-c C-x C-a`, confirm it lands in the mirrored `~/notes/archive/horizons/actions/<file>.org`, and confirm `prilepp/action-move-to-context` (`C-c m`) and the deadlines agenda view (`C-c v d`) still work against the active `actions` directory afterward.
- [x] 8.3 Confirm `org-refile-targets` (`C-c C-w` inside any horizon file) never lists anything from `~/notes/archive/` (no code change needed for this - confirms design.md's Context assumption holds in practice).
- [x] 8.4 `git diff` review: confirm only `init-horizon-types.el`, `init-horizon-archive.el` (new), `init-find-entity.el`, and `init.el` changed, and that `init-projects.el`/`init-files.el` (the macro call sites) did not need any edits.
