# emacs-horizon-archive Specification

## Purpose

Lets the six GTD horizon types (Action, Project, Area, Goal, Vision, Life) be archived and restored under a mirrored `~/notes/archive/...` directory structure, and keeps links into archived content working, so completed/inactive entries can be moved out of the active working set without breaking references to them.

## Requirements

### Requirement: Mirrored archive path mapping

For any file or directory path under `~/notes/`, the system SHALL define its corresponding archive path as the same path with the `~/notes/` prefix replaced by `~/notes/archive/`, preserving every path segment after that prefix unchanged (including the `horizons/` segment).

#### Scenario: Mapping a project file path
- **WHEN** the system computes the archive path for `~/notes/horizons/proj/Mail Server.org`
- **THEN** the result is `~/notes/archive/horizons/proj/Mail Server.org`

#### Scenario: Mapping is symmetric
- **WHEN** the system computes the archive path for an already-active path, then computes the corresponding active path for that archive path
- **THEN** the result equals the original active path

### Requirement: Archive an entry

The system SHALL expose a command that, given a horizon type (one of Action, Project, Area, Goal, Vision, Life) and the name of an existing active entry of that type, moves that entry's `.org` file to its mirrored archive path, creating any missing archive directories, and then refreshes `id:` link resolution for the moved file's contents so that existing `id:` links into it keep resolving.

#### Scenario: Archiving an existing project
- **WHEN** the user invokes the archive command, selects "Project", and selects an existing project name
- **THEN** that project's `.org` file no longer exists at its active path under `~/notes/horizons/proj/` and instead exists at the mirrored path under `~/notes/archive/horizons/proj/`, with its content unchanged

#### Scenario: id: links into an archived entry still resolve
- **WHEN** a heading inside an entry has an `:ID:` property that is the target of an `id:` link elsewhere in the notes, and that entry is then archived
- **THEN** following the existing `id:` link still opens that heading, now inside the archived file

### Requirement: Restore an archived entry

The system SHALL expose a command that, given a horizon type and the name of an existing archived entry of that type, moves that entry's `.org` file back to its mirrored active path, creating any missing active directories, and then refreshes `id:` link resolution for the moved file's contents.

#### Scenario: Restoring a previously archived project
- **WHEN** the user invokes the restore command, selects "Project", and selects an existing archived project name
- **THEN** that project's `.org` file no longer exists under `~/notes/archive/horizons/proj/` and instead exists again at its original active path under `~/notes/horizons/proj/`, with its content unchanged

### Requirement: Following a link to an archived entry does not recreate an empty active file

For every horizon type, when the system resolves an entry name to a file path (e.g. to follow an org link, or to open/create an entry by name), if no active file exists for that name but an archived file exists at the mirrored archive path, the system SHALL resolve to the existing archived file instead of creating a new, empty active file.

#### Scenario: Following a link into an archived project
- **WHEN** an org link `[[project:Mail Server]]` exists, "Mail Server" has since been archived, and the user follows that link
- **THEN** the system opens the existing archived file at `~/notes/archive/horizons/proj/Mail Server.org`, and does not create a new empty file at `~/notes/horizons/proj/Mail Server.org`

#### Scenario: Resolving a genuinely new entry still creates it actively
- **WHEN** the user opens/creates an entry by a name that exists neither actively nor in the archive
- **THEN** the system creates a new active file for it, exactly as before this capability existed

### Requirement: Archiving a heading redirects into the mirrored archive file

For every file belonging to one of the six horizon types, invoking Org's built-in subtree-archiving command on a heading SHALL move that heading into the mirrored archive file (the archive path corresponding to the current file), rather than Org's default same-directory `_archive` file.

#### Scenario: Archiving a DONE action heading
- **WHEN** the user marks a heading `DONE` inside `~/notes/horizons/actions/org.org` and invokes Org's subtree-archive command on it
- **THEN** the heading (with its properties, e.g. `ARCHIVE_TIME`, preserved as Org's archiving normally preserves them) is appended into `~/notes/archive/horizons/actions/org.org`, and no longer appears in `~/notes/horizons/actions/org.org`

#### Scenario: Archiving a heading in a non-horizon file is unaffected
- **WHEN** the user invokes Org's subtree-archive command on a heading in a file that does not belong to any of the six horizon types (e.g. a Zettel note)
- **THEN** Org's default archiving destination and behavior for that file are unchanged by this capability
