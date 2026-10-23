## 1. Utility extraction

- [x] 1.1 Create `lisp/init-utils.el` with `prilepp/slugify` moved out of `init-contacts.el` (with its existing docstring), a `(provide 'init-utils)` footer, and grep the rest of `lisp/*.el` for any other function called from a file other than the one that defines it; move each such function into `init-utils.el` too. Verify: `grep -rn "defun prilepp/slugify" lisp/` shows only `init-utils.el`.
- [x] 1.2 Remove `prilepp/slugify` (and any other moved function) from `init-contacts.el`. Verify: `grep -n "prilepp/slugify" lisp/init-contacts.el` returns nothing.

## 2. Rename the generic GTD-list-type layer

- [x] 2.1 Rename `lisp/init-horizon-types.el` to `lisp/init-gtd-list-types.el` (git mv), rename its `-*- lexical-binding` header comment and Commentary to say "GTD list type" instead of "horizon type", and update the `(provide 'init-horizon-types)` footer to `(provide 'init-gtd-list-types)`.
- [x] 2.2 Within that file, rename every generic symbol containing "horizon" to the "gtd-list" equivalent per design.md's Symbol renames table (`prilepp/horizon-types` → `prilepp/gtd-list-types`, `prilepp/horizon-type--register` → `prilepp/gtd-list-type--register`, `prilepp/horizon--title-cache`/`--read-title` → `prilepp/gtd-list--title-cache`/`--read-title`, `prilepp/horizon-file-title` → `prilepp/gtd-list-file-title`, `prilepp/horizon--label-entries` → `prilepp/gtd-list--label-entries`, `prilepp/horizon-entries` → `prilepp/gtd-list-entries`, `prilepp/horizon-entry-name` → `prilepp/gtd-list-entry-name`, `prilepp/define-horizon-type` → `prilepp/define-gtd-list-type`). Verify: `grep -n "horizon" lisp/init-gtd-list-types.el` returns no hits.
- [x] 2.3 Rename `lisp/init-horizon-archive.el` to `lisp/init-gtd-list-archive.el` (git mv), update its Commentary (including the "loaded after init-projects/init-files" note to say "loaded after init-gtd-lists"), its `require 'init-horizon-types` to `require 'init-gtd-list-types`, and its `(provide ...)` footer.
- [x] 2.4 Within that file, rename `prilepp/horizon-archived-entries`/`prilepp/horizon-archived-names` → `prilepp/gtd-list-archived-entries`/`prilepp/gtd-list-archived-names`, `prilepp/horizon-type--prompt` → `prilepp/gtd-list-type--prompt`, `prilepp/horizon--move-file` → `prilepp/gtd-list--move-file`, `prilepp/horizon-archive-location--maybe-set` → `prilepp/gtd-list-archive-location--maybe-set`, and every reference to the registry/macro renamed in 2.2. Leave `prilepp/archive-entry`, `prilepp/restore-entry`, `prilepp/archive-path`, `prilepp/active-path`, `prilepp/notes-root`, `prilepp/archive-root`, `prilepp/ensure-file--check-archive` as-is (no "horizon" in their names). Verify: `grep -n "horizon" lisp/init-gtd-list-archive.el` returns no hits other than in `~/notes/horizons/` path strings.

## 3. Merge the concrete list-type declarations

- [x] 3.1 Create `lisp/init-gtd-lists.el` with the five `prilepp/define-horizon-type` calls from `init-projects.el` (proj, aor, life, goals, vision) and the `actions` call from `init-files.el`, each renamed to `prilepp/define-gtd-list-type`, unchanged otherwise (same directory/function/link-word arguments). Verify: `emacs --batch --eval "(with-temp-buffer (insert-file-contents \"lisp/init-gtd-lists.el\") (check-parens))"` succeeds (balanced parens).
- [x] 3.2 Move `prilepp/agenda-deadlines`, its `org-agenda-custom-commands` setq, and `prilepp/action-move-to-context` from `init-files.el` into `init-gtd-lists.el`, next to the `actions` declaration.
- [x] 3.3 Add the `agendas` declaration to `init-gtd-lists.el` via `prilepp/define-gtd-list-type` per design.md (directory `~/notes/agendas/`, list/ensure/find function names unchanged from today, `:default-content nil`, `:link-word nil`), and delete the hand-written `prilepp/agendas--list-entries`, `prilepp/agendas-ensure-file`, `prilepp/agendas-find` from `init-files.el`. Verify: `grep -n "defun prilepp/agendas" lisp/*.el` shows no hand-written definitions left (only the macro-generated ones, invisible to grep since they're generated at macro-expansion time - confirm instead via `emacs --batch -l lisp/init-gtd-list-types.el -l lisp/init-gtd-lists.el --eval "(fboundp 'prilepp/agendas-find)"` prints `t`).
- [x] 3.4 Add `(provide 'init-gtd-lists)` and a Commentary describing it as "All GTD list-type declarations: Action, Project, Area, Goal, Vision, Life, Agenda."

## 4. Slim down the remaining files

- [x] 4.1 Remove the moved declarations/commands from `init-projects.el`, leaving only the `prilepp/routine-*` functions; update its Commentary to describe it as Routine-only. Rename it to `lisp/init-routines.el` (git mv) and its `(provide 'init-projects)` footer to `(provide 'init-routines)`.
- [x] 4.2 Add `(require 'init-utils)` near the top of `init-routines.el` (it calls `prilepp/slugify` in `prilepp/routine-insert-new`). Verify: `grep -n "require 'init-utils" lisp/init-routines.el` finds it.
- [x] 4.3 Update `init-files.el`'s Commentary to describe only what remains (quick-open commands, journal, heading link type), now that the horizon/agenda material has moved out.

## 5. Update cross-file references

- [x] 5.1 In `init-find-entity.el`, update `(require 'init-horizon-types)` and `(require 'init-horizon-archive)` to `(require 'init-gtd-list-types)` / `(require 'init-gtd-list-archive)`, rename `prilepp/entity-sources--horizon` to `prilepp/entity-sources--gtd-list` and every internal reference to the renamed registry/helpers it calls (`prilepp/horizon-types`, `prilepp/horizon-entries`, `prilepp/horizon-archived-names`).
- [x] 5.2 Replace the hand-written `:name "Agenda"` source block in `prilepp/entity-sources` with `(prilepp/entity-sources--gtd-list "Agenda" ?a 'agendas)`, in the same position in the list. Verify: `grep -n '"Agenda"' lisp/init-find-entity.el` shows only the one-line call, no `:items`/`:action`/`:new`/`:link` block.
- [x] 5.3 Grep the whole `lisp/` directory for the literal string `horizon` and confirm every remaining hit is either `my/org-horizon-files` (in `init-org.el`, intentionally unchanged per design.md) or a `~/notes/horizons/` path string, not a renamed symbol. Fix any other hit found.

## 6. Wire up `init.el`

- [x] 6.1 Update `init.el`'s `require` list to the new order from design.md: `init-paths, init-packages, init-basics, init-completion, init-org, init-utils, init-gtd-list-types, init-gtd-lists, init-files, init-routines, init-gtd-list-archive, init-contacts, init-calendar, init-find-entity, init-dashboard`.

## 7. Verification

- [ ] 7.1 Start Emacs with this config (`emacs -Q -l ~/.config/emacs/init.el` or the user's normal launch) and confirm it reaches the dashboard buffer with no `void-function`/`void-variable`/`Symbol's function definition is void` error in `*Messages*` or `*Warnings*`.
- [ ] 7.2 `C-c n`, narrow to Agenda (`a`): confirm existing agendas are still listed and open correctly (unchanged active behavior).
- [ ] 7.3 Create a new agenda via `C-c n` (typed, non-matching name): confirm the created file starts with `#+title: NAME` (new behavior per design.md).
- [ ] 7.4 `C-c a a` (archive): confirm "Agenda" is now offered as an archive type, and archiving an existing agenda moves its file to `~/notes/archive/agendas/`.
- [ ] 7.5 `C-c a r` (restore): confirm the archived agenda from 7.4 is offered and restoring moves it back to `~/notes/agendas/`.
- [ ] 7.6 `C-c n`, narrow to Agenda again: confirm the still-archived state (if any left archived) shows the "(archiviert)" annotation and sorts after active entries, matching the existing behavior already visible for e.g. Project.
- [ ] 7.7 Spot-check one each of Project/Area/Goal/Vision/Life/Action via `C-c n`, find command, and `C-c a a`/`C-c a r` to confirm their behavior (title display, archive, restore) is unchanged from before this change.
- [ ] 7.8 `C-c m` (move to context) on an Actions entry: confirm it still works (moved file, command unchanged).
