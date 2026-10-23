# emacs-tickler Specification

## Purpose
Provides a GTD tickler file: a single date-indexed Org file whose items stay hidden until the day they are scheduled for, then resurface and remain visible until handled, giving the user a place to defer something to a specific future date without seeing it beforehand.

## Requirements

### Requirement: Tickler file and entry format

The system SHALL treat `~/notes/tickler.org` as the tickler file: a single flat Org file (not a per-entry-file directory), created on first use if it does not already exist, seeded with a `#+TODO: TODO(t) | DONE(d)` keyword line. A tickler item SHALL be represented as an Org heading in that file carrying a `SCHEDULED` timestamp for the date it should resurface.

#### Scenario: File is created on first use
- **WHEN** neither the tickler agenda view nor the `C-c n` Tickler entry has been used before, and `~/notes/tickler.org` does not exist
- **THEN** invoking either of them creates `~/notes/tickler.org` containing the `#+TODO: TODO(t) | DONE(d)` line, without prompting for a name (unlike per-entry horizon types)

#### Scenario: Existing file is reused
- **WHEN** `~/notes/tickler.org` already exists
- **THEN** invoking the tickler agenda view or the `C-c n` Tickler entry opens/reads that same file rather than recreating it

### Requirement: Tickler items are not shown before their scheduled date

For a tickler item whose `SCHEDULED` date is in the future relative to the current day, the system SHALL NOT display it in the tickler agenda view.

#### Scenario: Future item is hidden
- **WHEN** a heading in `~/notes/tickler.org` has `SCHEDULED` set to a date after today, and the user invokes the tickler agenda view
- **THEN** that heading does not appear in the view

#### Scenario: Item becomes visible on its date
- **WHEN** a heading's `SCHEDULED` date is today
- **THEN** that heading appears in the tickler agenda view

### Requirement: Due tickler items remain visible until completed

For a tickler item whose `SCHEDULED` date is today or earlier, the system SHALL display it in the tickler agenda view on every day from its scheduled date onward, until it is marked `DONE` or its `SCHEDULED` date is changed to a future date.

#### Scenario: Unprocessed item stays visible the next day
- **WHEN** a tickler item was due yesterday, was not marked `DONE`, and was not rescheduled
- **THEN** it still appears in today's tickler agenda view

#### Scenario: Completed item disappears
- **WHEN** a tickler item due today is marked `DONE`
- **THEN** it no longer appears in the tickler agenda view, today or afterward

#### Scenario: Rescheduling to the future hides the item again
- **WHEN** a due tickler item's `SCHEDULED` date is changed to a future date
- **THEN** it no longer appears in the tickler agenda view until that new date arrives

### Requirement: Dedicated tickler agenda view

The system SHALL expose an agenda view, invoked via `C-c v t`, that shows only entries from `~/notes/tickler.org` (no other GTD file), limited to `SCHEDULED` entries due today or earlier.

#### Scenario: Tickler view excludes other files
- **WHEN** the user invokes the tickler agenda view
- **THEN** only entries from `~/notes/tickler.org` are shown, regardless of what other files have items scheduled or due today
