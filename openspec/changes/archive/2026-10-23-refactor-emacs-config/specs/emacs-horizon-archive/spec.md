## MODIFIED Requirements

### Requirement: Archive an entry

The system SHALL expose a command that, given a GTD list type (one of Action, Project, Area, Goal, Vision, Life, Agenda) and the name of an existing active entry of that type, moves that entry's `.org` file to its mirrored archive path, creating any missing archive directories, and then refreshes `id:` link resolution for the moved file's contents so that existing `id:` links into it keep resolving.

#### Scenario: Archiving an existing project
- **WHEN** the user invokes the archive command, selects "Project", and selects an existing project name
- **THEN** that project's `.org` file no longer exists at its active path under `~/notes/horizons/proj/` and instead exists at the mirrored path under `~/notes/archive/horizons/proj/`, with its content unchanged

#### Scenario: Archiving an existing agenda
- **WHEN** the user invokes the archive command, selects "Agenda", and selects an existing agenda name
- **THEN** that agenda's `.org` file no longer exists at its active path under `~/notes/agendas/` and instead exists at the mirrored path under `~/notes/archive/agendas/`, with its content unchanged

#### Scenario: id: links into an archived entry still resolve
- **WHEN** a heading inside an entry has an `:ID:` property that is the target of an `id:` link elsewhere in the notes, and that entry is then archived
- **THEN** following the existing `id:` link still opens that heading, now inside the archived file

### Requirement: Archiving a heading redirects into the mirrored archive file

For every file belonging to one of the seven GTD list types, invoking Org's built-in subtree-archiving command on a heading SHALL move that heading into the mirrored archive file (the archive path corresponding to the current file), rather than Org's default same-directory `_archive` file.

#### Scenario: Archiving a DONE action heading
- **WHEN** the user marks a heading `DONE` inside `~/notes/horizons/actions/org.org` and invokes Org's subtree-archive command on it
- **THEN** the heading (with its properties, e.g. `ARCHIVE_TIME`, preserved as Org's archiving normally preserves them) is appended into `~/notes/archive/horizons/actions/org.org`, and no longer appears in `~/notes/horizons/actions/org.org`

#### Scenario: Archiving a heading in a non-horizon file is unaffected
- **WHEN** the user invokes Org's subtree-archive command on a heading in a file that does not belong to any of the seven GTD list types (e.g. a Zettel note)
- **THEN** Org's default archiving destination and behavior for that file are unchanged by this capability
