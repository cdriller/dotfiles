## MODIFIED Requirements

### Requirement: Unified node picker

The system SHALL expose a single `C-c n` binding that opens a completion picker aggregating every node type: Action, Project, Area, Goal, Vision, Life, Agenda, Zettel, Literature, Person, Routine, Someday, and Heading. Selecting a candidate with RET SHALL open/visit that node's location. Pressing `C-i` while a candidate is highlighted SHALL insert an org link to it at point in the buffer where `C-c n` was invoked, without opening it. Pressing `C-c` while a candidate is highlighted SHALL copy an org link to it to the clipboard/kill-ring, without opening it. The behavior for the node types that existed under the previous `C-c o` binding (Action, Project, Area, Goal, Vision, Life, Agenda, Zettel, Literature, Person, Routine) SHALL be unchanged.

For the six node types that support archiving (Action, Project, Area, Goal, Vision, Life), the picker's candidates for that type SHALL also include that type's archived entries, in addition to its active entries. Within each such type's candidates, every archived entry SHALL be ordered after every active entry (lowest priority), so active entries are always seen and selected first. Selecting an archived candidate with RET SHALL open the archived file directly, without recreating an active file of the same name; `C-i`/`C-c` on an archived candidate SHALL insert/copy a link exactly as for an active entry of that type. Each archived candidate SHALL also be visually distinguishable from active candidates in the completion list (e.g. via an "(archiviert)" annotation), without altering the underlying name used for selection, RET, `C-i`, or `C-c`.

#### Scenario: Opening a node
- **WHEN** the user presses `C-c n`, narrows/selects a Zettel candidate, and presses RET
- **THEN** Emacs visits that org-roam node, exactly as `C-c o` did before this change

#### Scenario: Inserting a link to a node
- **WHEN** the user presses `C-c n`, highlights a Project candidate, and presses `C-i`
- **THEN** Emacs inserts an org link to that project at point, without opening the project file

#### Scenario: Copying a link to a node
- **WHEN** the user presses `C-c n`, highlights a Person candidate, and presses `C-c`
- **THEN** Emacs copies an org link to that person's note to the kill-ring/clipboard, without opening it

#### Scenario: Archived entries appear after active entries of the same type
- **WHEN** the user presses `C-c n`, narrows to the Project source, and that project type has both active and archived projects
- **THEN** every active project candidate is listed before every archived project candidate

#### Scenario: Selecting an archived candidate opens the archived file
- **WHEN** the user presses `C-c n`, narrows to the Project source, selects an archived project candidate, and presses RET
- **THEN** Emacs opens that project's file from `~/notes/archive/horizons/proj/`, and does not create a new file under `~/notes/horizons/proj/`

#### Scenario: Archived candidates are visually marked
- **WHEN** the user presses `C-c n` and narrows to a source (Action, Project, Area, Goal, Vision, or Life) that has at least one archived entry
- **THEN** that entry's candidate is shown with a visible annotation (e.g. "(archiviert)") distinguishing it from active candidates, in addition to being ordered after all active entries

#### Scenario: Non-archivable node types are unaffected
- **WHEN** the user presses `C-c n` and narrows to the Zettel, Literature, Person, Routine, Someday, Agenda, or Heading source
- **THEN** the candidates shown are exactly the same as before this capability existed - no archived/low-priority grouping applies to these sources
