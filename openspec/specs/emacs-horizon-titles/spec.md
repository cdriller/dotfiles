# emacs-horizon-titles Specification

## Purpose

Makes horizon entries (Action, Project, Area, Goal, Vision, Life) identifiable by the title stored inside their org file, the way org-roam notes are, instead of by their filename, wherever the user searches or picks one.

## Requirements

### Requirement: Horizon entries are shown by their file title

For each horizon type (Action, Project, Area, Goal, Vision, Life), every picker that lists that type's entries SHALL show each entry by the title declared in its file with a `#+title:` keyword (matched case-insensitively, value trimmed of surrounding whitespace), not by its filename. This applies to the horizon sources of the `C-c n` picker, the entity-link prompt used when setting `WAITING_FOR`, each type's find command, each type's insert-link command, the link completion offered by `org-insert-link` for each type's link word, the archive and restore commands, and the move-to-context command. The title SHALL be read from the file's own content, so a title changed in the file is shown the next time a picker is opened without any further action. Archived entries SHALL be shown by the title in their archived file.

#### Scenario: Entry with a title is listed by title
- **WHEN** the file `~/notes/horizons/proj/Mail Server.org` contains the line `#+title: Self-hosted Mail`, and the user opens the Project source of `C-c n`
- **THEN** the candidate is labelled `Self-hosted Mail`, and no candidate labelled `Mail Server` is shown for that file

#### Scenario: Selecting a titled entry opens its file
- **WHEN** the user selects the candidate `Self-hosted Mail` from the Project source of `C-c n` and presses RET
- **THEN** Emacs opens `~/notes/horizons/proj/Mail Server.org`, and no new file named after the title is created

#### Scenario: Title change is picked up
- **WHEN** the user edits the `#+title:` line of a horizon file, saves it, and opens a picker again
- **THEN** the candidate for that file shows the new title

#### Scenario: Archived entry is listed by its title
- **WHEN** `~/notes/archive/horizons/proj/Old Thing.org` contains `#+title: Legacy Migration`, and the user opens the Project source of `C-c n`
- **THEN** the candidate `Legacy Migration` is shown after all active project candidates and is annotated as archived

#### Scenario: Other pickers use titles too
- **WHEN** the user invokes the archive command (`C-c a a`), selects "Project", and looks at the entries offered
- **THEN** each entry is labelled by its title, and selecting one archives that entry's file

### Requirement: Filename fallback when a file has no title

When a horizon file has no `#+title:` keyword (or its value is empty), the system SHALL use the file's name without the `.org` extension as that entry's label, exactly as before this capability existed.

#### Scenario: Untitled file keeps its filename label
- **WHEN** `~/notes/horizons/actions/build.org` has no `#+title:` line and the user opens the Action source of `C-c n`
- **THEN** the candidate is labelled `build`

### Requirement: Identical titles remain individually selectable

When two or more entries of the same horizon type would show the same label (equal titles, or a title equal to another entry's filename fallback), the system SHALL make their labels distinct by appending the entry's filename, so that every entry stays selectable and each selection opens the correct file. Entries with a unique label SHALL NOT be altered.

#### Scenario: Two projects share a title
- **WHEN** `a.org` and `b.org` in `~/notes/horizons/proj/` both contain `#+title: Backup`, and the user opens the Project source of `C-c n`
- **THEN** two candidates are shown whose labels differ and each identify their file (for example `Backup (a)` and `Backup (b)`), and selecting each opens the corresponding file

### Requirement: Links keep addressing the file, with the title as description

Links created for a horizon entry from a picker SHALL keep addressing the entry by its file (its filename-based link target, e.g. `[[project:NAME]]` or `[[file:PATH]]`), and SHALL use the entry's title as the link description. Following an existing link SHALL behave exactly as before this capability existed, independent of the file's title.

#### Scenario: Inserting a link to a titled project
- **WHEN** the user presses `C-c n`, highlights the candidate `Self-hosted Mail` for `Mail Server.org`, and presses `C-i`
- **THEN** Emacs inserts a link whose target resolves to `~/notes/horizons/proj/Mail Server.org` and whose description is `Self-hosted Mail`

#### Scenario: Existing links keep working after a title is added
- **WHEN** a note contains `[[project:Mail Server]]` and `Mail Server.org` later receives `#+title: Self-hosted Mail`, and the user follows the link
- **THEN** Emacs opens `~/notes/horizons/proj/Mail Server.org`

### Requirement: Creating a horizon entry writes its title

When the system creates a new horizon file for any of the six types, it SHALL write `#+title: NAME`, with NAME being the name the user entered, as the first line of the new file, before any other seeded content. A name that resolves to an existing active or archived entry SHALL NOT create or modify a file. Creating an entry SHALL NOT change any existing file's content.

#### Scenario: New project gets a title
- **WHEN** the user creates a project named `Learn Rust` through `C-c n` or the project find command, and no such entry exists
- **THEN** `~/notes/horizons/proj/Learn Rust.org` is created whose first line is `#+title: Learn Rust`, followed by the project's usual seeded content

#### Scenario: New area without other seeded content
- **WHEN** the user creates an area named `Fitness` and no such entry exists
- **THEN** `~/notes/horizons/aor/Fitness.org` is created containing `#+title: Fitness`

#### Scenario: Existing files are not touched
- **WHEN** the user opens a picker, selects an existing untitled horizon entry, and opens it
- **THEN** the file's content on disk is unchanged
