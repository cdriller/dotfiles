## 1. Rebind the node picker

- [x] 1.1 In `emacs/.config/emacs/lisp/init-find-entity.el`, change `(global-set-key (kbd "C-c o") #'prilepp/find-entity)` to bind `C-c n` instead, and update the which-key call from `"C-c o" "find entity"` to `"C-c n" "nodes"`. Verify pressing `C-c n` opens the picker and `C-c o` reports "C-c o is undefined".

## 2. Add the Someday source

- [x] 2.1 In `prilepp/entity-sources` (`init-find-entity.el`), add a new source with `:name "Someday"`, a fixed single-item `:items` (e.g. returning `'("Someday")`), `:action`/`:new` opening `someday.org` (reuse `my/edit-someday-file` or the `someday.org` path variable from `init-files.el`), and `:link` producing a `file:` link to it. Verify: `C-c n`, narrow/select Someday, RET opens `someday.org`.
- [x] 2.2 Verify `C-i` and `C-c` on the Someday candidate insert/copy a `file:` link to `someday.org` respectively.

## 3. Add the Heading source

- [x] 3.1 In `init-find-entity.el`, add a new source with `:name "Heading"` and a narrow key, adapting `org-refile-get-location`'s interactive lookup (from `my/insert-link-to-org-heading` in `init-files.el`) into the `:items`/`:action`/`:link` shape `consult--multi` expects (see design.md "Heading source reuses `org-refile-get-location`" for the two implementation options). Verify: `C-c n`, narrow to Heading, select a heading, RET jumps to it.
- [x] 3.2 Verify `C-i` on a Heading candidate inserts an `id:` link equivalent to the old `C-c i h` behavior, and `C-c` copies the same link.

## 4. Remove redundant single-purpose bindings

- [x] 4.1 In `emacs/.config/emacs/lisp/init-org.el`, remove the `"C-c i z" . org-roam-node-insert` bind and its which-key label (~lines 25-29), and the citar `"C-c i l" . citar-insert-citation` bind and its which-key label (~lines 61-64).
- [x] 4.2 In `emacs/.config/emacs/lisp/init-projects.el`, remove all five `global-set-key "C-c i <leaf>"` + matching `which-key-add-key-based-replacements` pairs (`j`=project ~64-66, `a`=area ~114-116, `i`=life ~205-207, `g`=goal ~255-257, `v`=vision ~305-307).
- [x] 4.3 In `emacs/.config/emacs/lisp/init-contacts.el`, remove `global-set-key "C-c i p"` and its which-key label (~lines 83-85).
- [x] 4.4 In `emacs/.config/emacs/lisp/init-files.el`, remove `global-set-key (kbd "C-c s") #'my/edit-someday-file` and its which-key label (~lines 21-23).
- [x] 4.5 In `emacs/.config/emacs/lisp/init-files.el`, remove `global-set-key (kbd "C-c i h") #'my/insert-link-to-org-heading` and its which-key label (~lines 150-152); keep or remove `my/insert-link-to-org-heading` itself depending on whether the Heading source (task 3.1) reuses it internally.
- [x] 4.6 Verify `C-c i` and `C-c s` are both undefined after reload (Emacs reports "is undefined" for each).

## 5. Manual verification

- [x] 5.1 Reload the Emacs config (restart Emacs or `M-x load-file` on init.el) and press `C-c n`, confirming which-key shows the "nodes" label and the picker opens with all sources including Someday and Heading.
- [x] 5.2 Confirm `C-c v` still shows the unchanged "view" which-key popup with leaves `b`, `u`, `c`, `d` and that `C-c v d` still opens the deadlines agenda view.
- [x] 5.3 Spot-check RET/`C-i`/`C-c` on at least three different source types (e.g. Zettel, Person, Someday) to confirm open/insert/copy all behave as specified.
- [x] 5.4 Confirm `prilepp/read-entity-link` (used by the WAITING-FOR prompt) still works and now offers Someday/Heading as selectable targets too.
