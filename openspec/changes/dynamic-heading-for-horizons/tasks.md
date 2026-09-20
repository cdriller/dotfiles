## 1. Prerequisite

- [ ] 1.1 Confirm the uncommitted `init-horizon-archive.el` changes (`prilepp/horizon-archived-names` active-exclusion, `prilepp/ensure-file--check-archive` active-first) are committed on the branch this change is applied to, and verify with `git diff --stat -- emacs/.config/emacs/lisp/init-horizon-archive.el` showing no unrelated pending edits

## 2. Title reading and entry list (init-horizon-types.el)

- [ ] 2.1 Add `prilepp/horizon-file-title` (reads the first 4 KiB, stops at the first `^\*` heading, case-insensitive `#+title:`, nil when absent/empty) with an mtime-validated cache; verify with an `emacs --batch` script over temp files covering: titled file, untitled file, empty title, `#+TITLE:` casing, `#+title:` after a heading (ignored), and re-reading after the file is edited
- [ ] 2.2 Add `prilepp/horizon-entries` returning `(LABEL NAME TITLE)` lists for a horizon slug (active entries first, optional archived entries after, filename fallback, ` (NAME)` disambiguation across the combined list); verify in the same batch script with two files sharing a title and with an archived/active mix that each label is unique and maps to the right NAME
- [ ] 2.3 In `prilepp/define-horizon-type`, write `#+title: NAME\n` before `default-content` in the generated ensure-fn; verify in batch by creating a nil-content, a static-content and a `%s`-content entry in a temp directory and inspecting the first line and remaining content of each new file, and that calling ensure-fn on an existing file leaves it byte-identical
- [ ] 2.4 Switch the generated `*-find`, `*-insert-*-link` (link text `[[word:NAME][TITLE]]`) and `*-complete` functions to complete over entry labels and map back to NAME (a label with no match is treated as a new NAME); verify by byte-compiling init-horizon-types.el without warnings and by a batch run stubbing `completing-read` that the insert function outputs the expected link for a titled entry and a new name

## 3. Archive integration (init-horizon-archive.el)

- [ ] 3.1 Add an archived-entries variant that builds `(LABEL NAME TITLE)` from `prilepp/horizon-archived-names` using the titles in the archived files, and make `prilepp/horizon-entries` use it for `include-archived`; verify in batch against a temp notes tree (active + archived files of the same type) that archived labels come after active ones and use the archived file's title
- [ ] 3.2 Update `prilepp/archive-entry` and `prilepp/restore-entry` to offer labels and resolve the selection to NAME before moving files; verify in batch (stubbed `completing-read`) that archiving/restoring a titled entry moves the file named by NAME and not one named by the title

## 4. Pickers (init-find-entity.el, init-files.el)

- [ ] 4.1 Rework the Action/Project/Area/Goal/Vision/Life sources in `prilepp/entity-sources` to use entry labels as `:items`, resolve label→entry in `:action`, `:new` (miss ⇒ typed text is the new NAME), `:annotate` (archived marker) and `:link` (`[[file:PATH][TITLE]]`), removing the six-fold duplication if a small shared builder does it more simply; verify by byte-compiling init-find-entity.el and, in a running Emacs with `M-x eval-buffer` on the changed files, opening `C-c n` and checking that a titled project shows its title, RET opens the right file, `C-i` inserts a link with the right target and description, and typing an unused name creates `NAME.org` starting with `#+title: NAME`
- [ ] 4.2 Update `prilepp/action-move-to-context` to complete over action-context labels and map back to NAME; verify with a titled context file that the subtree lands in the correct file
- [ ] 4.3 Confirm `prilepp/read-entity-link` (used for `WAITING_FOR`) shows titles for horizon sources without further code changes; verify by setting an action to WAITING and picking a titled project

## 5. End-to-end verification

- [ ] 5.1 Manually verify in a running Emacs against real notes: add `#+title:` to one file per horizon type, check `C-c n` (active and archived entries, disambiguation with two same-title copies), find, insert-link, `C-c a a`/`C-c a r`, and confirm untitled files still show their filenames and existing `[[project:...]]` links still open the same files
- [ ] 5.2 Run `openspec validate dynamic-heading-for-horizons --strict` and confirm it passes
