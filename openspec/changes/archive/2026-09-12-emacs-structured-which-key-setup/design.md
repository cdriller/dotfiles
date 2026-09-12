## Context

`prilepp/find-entity` (`init-find-entity.el`) already implements a `consult--multi` picker over a list of sources (each with `:name`, `:narrow`, `:items`, `:action`, `:new`, `:link`), bound to `C-c o`, with a minibuffer-local keymap where `C-i` and `C-c` throw the highlighted candidate out of the `consult--multi` call to run `insert`/`copy` on its `:link` instead of the normal `:action`. Separately, five files still bind single-purpose, insert-only `C-c i <leaf>` commands (`org-roam-node-insert`, `citar-insert-citation`, `prilepp/org-insert-*-link`, `prilepp/org-insert-contact-link`, `my/insert-link-to-org-heading`), and `init-files.el` binds standalone `C-c s` for `someday.org`. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Rebind `prilepp/find-entity` from `C-c o` to `C-c n`, preserving all existing sources and the RET/C-i/C-c behavior unchanged.
- Add a Someday source (single-candidate: `someday.org` itself) and a Heading source (wrapping the existing `org-refile-targets`-based lookup from `my/insert-link-to-org-heading`) to `prilepp/entity-sources`.
- Remove the now-redundant single-purpose `C-c i <leaf>` bindings and `C-c s`, along with their which-key labels, since the picker's `C-i`/`C-c` actions cover the same functionality.

**Non-Goals:**
- No change to the `C-c v` group's bindings or behavior.
- No change to `prilepp/read-entity-link` or the WAITING-FOR prompt flow, which already read from `prilepp/entity-sources` and pick up the new sources automatically.
- No new packages or completion framework changes - reuse `consult--multi`/vertico exactly as `prilepp/find-entity` already does.

## Decisions

- **Rebind rather than duplicate**: `C-c n` becomes the new binding for the existing `prilepp/find-entity` function; `C-c o` is freed. Rationale: avoids maintaining two near-identical pickers.
- **Someday as a single-candidate source**: unlike other sources (which list many named entries), Someday's `:items` returns a single fixed candidate (e.g. `"Someday"`), `:action`/`:new` both open `someday.org`, and `:link` produces a `file:` link to it. This fits the existing source shape without special-casing the picker's core logic.
- **Heading source reuses `org-refile-get-location`**: the new Heading source's `:items` cannot be a simple static/cached list the way named collections are (refile targets are looked up interactively via `org-refile-get-location`, which itself prompts). To fit the `consult--multi` source shape (`:items` must return a list, not prompt), the Heading source will need its own narrow-scoped handling — `:items` returns nothing/lazy and the source's `:action`/`:new`/`:link` call `org-refile-get-location` directly when the user narrows to `?h` and types a query, mirroring how `my/insert-link-to-org-heading` itself worked. If this proves awkward inside `consult--multi`'s source protocol during implementation, the alternative is a small dedicated wrapper function that adapts `org-refile-get-location` into the `:items`/`:link` shape - a task-level implementation detail, not a spec change.
- **Which-key label**: replace `"C-c o" "find entity"` with `"C-c n" "nodes"` in `init-find-entity.el` (colocated with the binding, following the existing convention).
- **Removal, not deprecation**: the redundant `C-c i <leaf>` bindings and `C-c s` are deleted outright (per proposal), not kept as aliases, to avoid two ways to do the same thing.

## Risks / Trade-offs

- [Heading source doesn't fit the static-list `:items` shape cleanly, unlike other sources] → Mitigation: flagged as an open question below; implementation may need a small adapter, but the *behavior* (RET jumps, C-i inserts, C-c copies a heading link) stays as specified regardless of the internal shape.
- [Muscle memory disruption: `C-c o`→`C-c n`, and loss of `C-c i ...`/`C-c s`] → Mitigation: which-key label makes the new binding discoverable; this is an accepted, explicit BREAKING change per the proposal.
- [Missing a leaf during removal of the 5-file `C-c i` bindings] → Mitigation: tasks.md enumerates every occurrence explicitly.

## Open Questions

- Exact mechanics of adapting `org-refile-get-location`'s interactive-prompt shape into a `consult--multi` source's `:items`/`:link` contract are left to implementation (tasks.md); the externally observable behavior (RET/C-i/C-c on a heading candidate) is fixed by the spec and does not depend on the answer.
