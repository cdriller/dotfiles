## Why

The GTD system already covers the "horizons of focus" (Action, Project, Area, Goal, Vision, Life) and flat single-file lists like `someday.org`, but has no tickler file: a place to file a reminder under a future date so it resurfaces exactly when that date arrives. Without it, date-deferred items either clutter an active context file early or get lost outside the system entirely.

## What Changes

- Add `~/notes/tickler.org`, a single flat Org file (analogous to `someday.org`) holding one heading per tickler item, scheduled via Org's `SCHEDULED` property and using a `TODO`/`DONE` keyword set so an item stops reappearing once handled.
- Add a new Org agenda custom command (key `"t"`, restricted to `tickler.org`, `:scheduled` entries only) that shows exactly the items due today or earlier - never items scheduled for a future date - relying on stock Org semantics (`SCHEDULED` entries are never shown ahead of their date, and stay visible once due until marked `DONE` or rescheduled).
- Bind `C-c v t` to invoke that agenda view, alongside the existing `C-c v d` (Deadlines) view under the `C-c v` "views" prefix.
- Add a `"Tickler"` source to the `C-c n` unified node picker (narrow key `t`), modeled on the existing `"Someday"` source, so `tickler.org` is reachable/editable from the picker. No `org-capture` template is added; new items are added by manually editing the file (directly or via the picker).

## Capabilities

### New Capabilities
- `emacs-tickler`: the tickler file's location and format, the "never shown before its scheduled date" and "stays visible until done" guarantees, and the dedicated `C-c v t` agenda view.

### Modified Capabilities
- `emacs-keybindings`: the "Unified node picker" requirement's enumerated node type list gains Tickler (alongside Action, Project, Area, Goal, Vision, Life, Agenda, Zettel, Literature, Person, Routine, Someday, Heading); the "View prefix group" requirement gains the new `C-c v t` leaf binding.

## Impact

- **Code**: `emacs/.config/emacs/lisp/init-files.el` (new agenda command extending the existing `org-agenda-custom-commands` list, new `C-c v t` binding), `emacs/.config/emacs/lisp/init-find-entity.el` (new `"Tickler"` source in `prilepp/entity-sources`).
- **Data**: new file `~/notes/tickler.org`, created on first use (find-or-create, like `someday.org`).
- **User-visible**: a new `C-c v t` keybinding and a new `t` entry in the `C-c n` picker; no changes to any existing command's behavior.
