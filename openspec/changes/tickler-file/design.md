## Context

See `proposal.md` - Why/What Changes for motivation. Relevant existing code:

- `init-files.el` currently sets `org-agenda-custom-commands` via a single `(setq org-agenda-custom-commands '(("d" "Deadlines (Actions)" ...)))` - a full replace, not an append. Adding the `"t"` Tickler command must extend this list rather than clobber the `"d"` entry.
- `init-find-entity.el`'s `prilepp/entity-sources` already has a `"Someday"` source (narrow key `?s`) that is the template for a flat single-file node: `:items` returns a constant one-element list, `:action`/`:new` both open the file, `:link` returns a `file:` link. `?t` is unused as a narrow key.
- Stock Org semantics already provide almost everything the spec needs: a `SCHEDULED` timestamp (unlike `DEADLINE`) is never shown in the agenda before its date regardless of `org-deadline-warning-days` (that variable only affects `DEADLINE` warnings), and `org-scheduled-past-days` (default effectively unlimited for this use) keeps a not-yet-`DONE` `SCHEDULED` entry appearing on every subsequent day. No custom "hide until date" logic is needed.

## Goals / Non-Goals

**Goals:**
- Reuse stock Org agenda/`SCHEDULED` behavior for the hide-until-due and stay-visible-until-done semantics, rather than writing custom date-filtering logic.
- Keep the new code the same shape as the existing Deadlines command and Someday source, so it reads as "one more of the same pattern," not a new subsystem.

**Non-Goals:**
- No `org-capture` template (confirmed with the user: manual editing only).
- No archiving support for tickler items - `emacs-horizon-archive` applies only to the six horizon types; tickler items are cleared by marking `DONE`, not archived.
- No repeating/recurring tickler items (e.g. `+1m` repeaters) - out of scope for this change; a plain one-shot `SCHEDULED` date is enough for the described use case, and Org's repeater syntax already works in any `SCHEDULED` field if the user wants it later without any code change.

## Decisions

**`SCHEDULED`, not `DEADLINE`.** `DEADLINE` entries appear early once inside the `org-deadline-warning-days` window (default 14 days), which is exactly the premature-visibility behavior the user wants to avoid. `SCHEDULED` entries appear starting on their date and not before, with no warning window to misconfigure.

**A file-scoped custom agenda command, not a filter on the existing Deadlines command.** The existing `"d"` command scans `prilepp/actions-directory` for `:deadline` entries. Tickler entries live in one fixed file and use `:scheduled`. Reusing the same command with different filters would require branching on invocation; a second, independent `org-agenda-custom-commands` entry (key `"t"`) mirrors the existing `"d"` entry's shape and keeps each command's file scope and entry type fixed and simple.

**Extend, don't replace, `org-agenda-custom-commands`.** Change the existing `(setq ... '(("d" ...)))` to a two-entry list (or use `add-to-list`/`push` before the `"d"` definition) so both commands coexist. This is purely a code-shape fix in `init-files.el`; no behavior of the `"d"` command changes.

**`#+TODO: TODO(t) | DONE(d)` header in `tickler.org`.** This is what makes "mark it DONE to stop it reappearing" possible - without a `DONE` state, nothing can leave the not-yet-handled set. Actions/Project files already seed a similar `#+TODO` line, so this matches existing file-creation conventions (see `emacs-horizon-titles`/`prilepp/define-horizon-type`'s `default-content`).

**Tickler as a `C-c n` source modeled on Someday, not a new bespoke open command.** The `emacs-keybindings` spec already removed `someday.org`'s standalone binding in favor of the picker; adding a parallel `my/edit-tickler-file` + dedicated keybinding would reintroduce the pattern that was deliberately consolidated away. Reusing the Someday shape (constant one-item `:items`, `:action`/`:new` = open, `:link` = `file:` link) keeps this consistent and is a few lines.

## Risks / Trade-offs

- [Forgetting to extend rather than replace `org-agenda-custom-commands`] → covered explicitly above and will be called out in `tasks.md`; a code review / manual check (`C-c v d` still works after the change) catches a regression immediately.
- [`org-scheduled-past-days` is a global user option someone could later set to a small number, silently breaking "stays visible until done"] → not mitigated in code (it's a stock Org variable, not something this change should touch or override); acceptable since it isn't set anywhere in this config today.
