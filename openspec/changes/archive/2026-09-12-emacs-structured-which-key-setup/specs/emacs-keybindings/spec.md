## Purpose

Defines the structured `C-c`-prefix keybindings in the Emacs config so that a single "nodes" picker covers every link/navigation target ("nodes") with open/insert/copy actions, and `C-c v` remains the home for cross-location aggregation ("views"), all discoverable via which-key.

## ADDED Requirements

### Requirement: Unified node picker

The system SHALL expose a single `C-c n` binding that opens a completion picker aggregating every node type: Action, Project, Area, Goal, Vision, Life, Agenda, Zettel, Literature, Person, Routine, Someday, and Heading. Selecting a candidate with RET SHALL open/visit that node's location. Pressing `C-i` while a candidate is highlighted SHALL insert an org link to it at point in the buffer where `C-c n` was invoked, without opening it. Pressing `C-c` while a candidate is highlighted SHALL copy an org link to it to the clipboard/kill-ring, without opening it. The behavior for the node types that existed under the previous `C-c o` binding (Action, Project, Area, Goal, Vision, Life, Agenda, Zettel, Literature, Person, Routine) SHALL be unchanged.

#### Scenario: Opening a node
- **WHEN** the user presses `C-c n`, narrows/selects a Zettel candidate, and presses RET
- **THEN** Emacs visits that org-roam node, exactly as `C-c o` did before this change

#### Scenario: Inserting a link to a node
- **WHEN** the user presses `C-c n`, highlights a Project candidate, and presses `C-i`
- **THEN** Emacs inserts an org link to that project at point, without opening the project file

#### Scenario: Copying a link to a node
- **WHEN** the user presses `C-c n`, highlights a Person candidate, and presses `C-c`
- **THEN** Emacs copies an org link to that person's note to the kill-ring/clipboard, without opening it

### Requirement: Someday as a node

The `C-c n` picker SHALL include `someday.org` as a selectable node candidate. RET SHALL open `someday.org`; `C-i` SHALL insert a link to it; `C-c` SHALL copy a link to it. `someday.org` SHALL NOT be reachable via a standalone `C-c s` binding after this change.

#### Scenario: Opening someday.org via the picker
- **WHEN** the user presses `C-c n`, selects the Someday candidate, and presses RET
- **THEN** Emacs opens `someday.org`

#### Scenario: Old someday binding removed
- **WHEN** the user presses `C-c s`
- **THEN** Emacs reports no binding is defined for that key

### Requirement: Org heading as a node

The `C-c n` picker SHALL include a Heading source that searches org headings across `org-refile-targets` (the same target set previously used by `my/insert-link-to-org-heading`). RET SHALL jump to the selected heading; `C-i` SHALL insert a link to it; `C-c` SHALL copy a link to it.

#### Scenario: Inserting a link to a heading via the picker
- **WHEN** the user presses `C-c n`, narrows to the Heading source, selects a heading, and presses `C-i`
- **THEN** Emacs inserts an `id:` link to that heading at point, equivalent to what `C-c i h` did before this change

### Requirement: Which-key label for the node picker

The system SHALL register a which-key label for `C-c n` describing it as the unified node picker (e.g. "nodes"), replacing the previous "find entity" label that was shown for `C-c o`.

#### Scenario: which-key shows the node label
- **WHEN** the user presses `C-c n` and pauses before completing the picker's prompt
- **THEN** which-key displays the "nodes" label for that binding

### Requirement: Redundant single-purpose node bindings removed

The system SHALL NOT bind `C-c i` or any of its former leaves (`C-c i z`, `C-c i l`, `C-c i j`, `C-c i a`, `C-c i i`, `C-c i g`, `C-c i v`, `C-c i p`, `C-c i h`) after this change, since their functionality is superseded by the `C-c n` picker's `C-i` insert action.

#### Scenario: Old insert prefix is no longer bound
- **WHEN** the user presses `C-c i`
- **THEN** Emacs reports no binding is defined for that prefix

### Requirement: View prefix group remains the home for aggregation views

The system SHALL continue to expose the existing `C-c v` prefix group ("view") with its current leaf bindings (backlinks, roam-ui, calendar, deadlines) unchanged, and this group SHALL remain the designated location for future cross-location aggregation views (e.g. a future "waiting for" view) added in later changes.

#### Scenario: Existing view bindings unaffected
- **WHEN** the user presses `C-c v d`
- **THEN** Emacs invokes the deadlines agenda view exactly as before this change
