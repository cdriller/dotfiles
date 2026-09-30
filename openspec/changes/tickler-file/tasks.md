## 1. Tickler agenda command (`init-files.el`)

- [x] 1.1 Change the existing `(setq org-agenda-custom-commands '(("d" ...)))` in `init-files.el` into a two-entry list (or an `add-to-list`/`push` before the `"d"` definition) adding a `"t"` "Tickler" command: `org-agenda-files` restricted to `(list (expand-file-name "~/notes/tickler.org"))`, `org-agenda-entry-types '(:scheduled)`, `org-agenda-span 'day`. Verify by evaluating the buffer and running `M-x org-agenda t` (or the new `prilepp/agenda-tickler` command below) with `~/notes/tickler.org` not yet existing - it should error/prompt cleanly rather than throw a `file-missing` from a stale command list, and running `M-x org-agenda d` afterward still shows Actions deadlines exactly as before.
- [x] 1.2 Add `prilepp/agenda-tickler` (interactive, calls `(org-agenda nil "t")`), mirroring `prilepp/agenda-deadlines`. Bind it to `C-c v t` and register the which-key label `"tickler"` for that key, next to the existing `C-c v d` wiring. Verify `C-c v t` opens the tickler agenda view and which-key shows "tickler" when the prefix is held.
- [x] 1.3 Manually create `~/notes/tickler.org` (or add find-or-create logic alongside the agenda command) seeded with `#+TODO: TODO(t) | DONE(d)`, then add one heading `SCHEDULED` for today and one for a future date. Verify `C-c v t` shows only today's heading, not the future one.
- [x] 1.4 Verify overdue behavior: change today's heading's `SCHEDULED` date to yesterday (without marking it `DONE`) and confirm it still appears in `C-c v t`; mark it `DONE` and confirm it disappears.

## 2. Tickler node in the `C-c n` picker (`init-find-entity.el`)

- [x] 2.1 Add a `"Tickler"` source (narrow key `?t`) to `prilepp/entity-sources`, modeled on the existing `"Someday"` source: `:items` returns a constant one-element list (e.g. `'("Tickler")`), `:action`/`:new` open (find-or-create) `~/notes/tickler.org`, `:link` returns `[[file:~/notes/tickler.org][Tickler]]`. Verify `C-c n`, narrow to `t`, RET opens `~/notes/tickler.org` (creating it with the `#+TODO` header if missing).
- [x] 2.2 Verify `C-i` and `C-c` on the Tickler candidate insert/copy a working `file:` link to `~/notes/tickler.org`, and that no other `C-c n` source's behavior changed (spot-check the Someday and Action sources still work).

## 3. Final checks

- [x] 3.1 Confirm no narrow-key collision: `?t` was unused before this change and is now used only by the Tickler source.
- [x] 3.2 Run through the `## Verification` scenarios in the approved plan end-to-end (future item hidden, becomes visible on its date, stays visible once overdue, disappears once `DONE`, reachable via `C-c n`).
