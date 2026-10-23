;;; init-gtd-list-archive.el --- Archive/restore for GTD list types -*- lexical-binding: t; -*-

;;; Commentary:
;; Generic archive/restore support for every GTD list type registered
;; in `prilepp/gtd-list-types' (see init-gtd-list-types.el): a
;; path-mirroring rule between ~/notes/... and ~/notes/archive/..., the
;; interactive `prilepp/archive-entry'/`prilepp/restore-entry' commands,
;; a fix so that following a link to an archived entry opens the
;; archived file instead of silently recreating an empty active one,
;; and a `find-file-hook' that redirects Org's built-in subtree
;; archiving (`C-c C-x C-a') into the mirrored archive file for
;; GTD-list-type buffers. Loaded after init-gtd-lists so the registry
;; is fully populated first. See design.md in the
;; "emacs-horizons-archive-functionality" change for the full
;; rationale.

;;; Code:

(require 'init-gtd-list-types)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Path mirroring

(defvar prilepp/notes-root (expand-file-name "~/notes/")
  "Root directory of all notes.")

(defvar prilepp/archive-root (expand-file-name "~/notes/archive/")
  "Root directory mirroring `prilepp/notes-root' for archived entries.")

(defun prilepp/archive-path (path)
  "Return the archive-mirrored path for the active PATH under `prilepp/notes-root'."
  (concat prilepp/archive-root
          (string-remove-prefix prilepp/notes-root (expand-file-name path))))

(defun prilepp/active-path (path)
  "Return the active path for the archive-mirrored PATH under `prilepp/archive-root'."
  (concat prilepp/notes-root
          (string-remove-prefix prilepp/archive-root (expand-file-name path))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Archive / restore commands

(defun prilepp/gtd-list-archived-names (slug)
  "Return the archived entry names (without .org) for GTD-list-type SLUG
that have no active counterpart, or nil if that type has no archive
directory yet.

A name is excluded here (even though a file for it exists under the
archive directory) when an active file of the same name also exists -
e.g. an actions context file that has had individual headings archived
out of it via `org-archive-subtree' while the file itself stays active.
Such a name is not a restorable/low-priority \"archived entry\" in the
sense `prilepp/restore-entry' and the `C-c n' picker mean; it is simply
the active entry, which already appears in the active list."
  (let* ((directory-var (plist-get (alist-get slug prilepp/gtd-list-types) :directory-var))
         (active-root (expand-file-name (symbol-value directory-var)))
         (root (prilepp/archive-path active-root)))
    (when (file-directory-p root)
      (seq-remove
       (lambda (name) (file-exists-p (expand-file-name (concat name ".org") active-root)))
       (mapcar #'file-name-sans-extension
               (directory-files root nil "\\.org\\'"))))))

(defun prilepp/gtd-list-archived-entries (slug)
  "Return (NAME . TITLE) pairs for the archived entries of GTD-list-type SLUG.
TITLE is the `#+title:' of the archived file, or nil. Feeds
`prilepp/gtd-list-entries', which builds the labels."
  (let* ((directory-var (plist-get (alist-get slug prilepp/gtd-list-types) :directory-var))
         (root (prilepp/archive-path (expand-file-name (symbol-value directory-var)))))
    (mapcar (lambda (name)
              (cons name (prilepp/gtd-list-file-title
                          (expand-file-name (concat name ".org") root))))
            (prilepp/gtd-list-archived-names slug))))

(defun prilepp/gtd-list-type--prompt (prompt)
  "Read a registered GTD-list-type slug with PROMPT; return its registry entry."
  (let ((slug (intern (completing-read
                        prompt
                        (mapcar #'symbol-name (mapcar #'car prilepp/gtd-list-types))
                        nil t))))
    (alist-get slug prilepp/gtd-list-types)))

(defun prilepp/gtd-list--move-file (old-path new-path)
  "Move the file at OLD-PATH to NEW-PATH, creating parent directories as
needed. Any open buffer visiting OLD-PATH is saved first, then
redirected to NEW-PATH. Refreshes `org-id-locations' for NEW-PATH so
existing `id:' links into it keep resolving."
  (let* ((old (expand-file-name old-path))
         (new (expand-file-name new-path))
         (buf (get-file-buffer old)))
    (when buf
      (with-current-buffer buf (save-buffer)))
    (make-directory (file-name-directory new) t)
    (rename-file old new)
    (when buf
      (with-current-buffer buf (set-visited-file-name new t t)))
    (org-id-update-id-locations (list new))
    new))

(defun prilepp/archive-entry ()
  "Archive an existing GTD-list entry: prompt for its type, then an
existing active entry of that type, and move its file to the mirrored
archive path."
  (interactive)
  (let* ((entry (prilepp/gtd-list-type--prompt "Archive type: "))
         (directory-var (plist-get entry :directory-var))
         (entries (prilepp/gtd-list-entries (plist-get entry :slug)))
         (name (prilepp/gtd-list-entry-name
                (completing-read "Archive entry: " (mapcar #'car entries) nil t)
                entries))
         (active-path (expand-file-name (concat name ".org") (symbol-value directory-var)))
         (archive-path (prilepp/archive-path active-path)))
    (prilepp/gtd-list--move-file active-path archive-path)
    (message "Archived \"%s\"" name)))

(defun prilepp/restore-entry ()
  "Restore an archived GTD-list entry: prompt for its type, then an
existing archived entry of that type, and move its file back to the
mirrored active path."
  (interactive)
  (let* ((entry (prilepp/gtd-list-type--prompt "Restore type: "))
         (slug (plist-get entry :slug))
         (directory-var (plist-get entry :directory-var))
         (archived (prilepp/gtd-list-archived-names slug))
         (entries (seq-filter (lambda (e) (member (nth 1 e) archived))
                              (prilepp/gtd-list-entries slug t)))
         (name (prilepp/gtd-list-entry-name
                (completing-read "Restore entry: " (mapcar #'car entries) nil t)
                entries))
         (archive-path (expand-file-name
                         (concat name ".org")
                         (prilepp/archive-path (symbol-value directory-var))))
         (active-path (prilepp/active-path archive-path)))
    (prilepp/gtd-list--move-file archive-path active-path)
    (message "Restored \"%s\"" name)))

(global-set-key (kbd "C-c a a") #'prilepp/archive-entry)
(global-set-key (kbd "C-c a r") #'prilepp/restore-entry)
(which-key-add-key-based-replacements
  "C-c a" "archive")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Stale-link fix: resolve archived entries instead of recreating them

(defun prilepp/ensure-file--check-archive (directory-var orig-fn name)
  "Around-advice for a GTD list type's ensure-fn (whose directory variable
is DIRECTORY-VAR): if no active file exists for NAME but one exists in
the mirrored archive directory, return that archived path directly
instead of calling ORIG-FN (which would otherwise create a new empty
active file). If an active file already exists for NAME - even when an
archive-mirrored file of the same name also exists, e.g. an actions
context file that has had individual headings archived out of it while
the file itself stays active - ORIG-FN (and therefore the active file)
always takes precedence."
  (let ((active-file (expand-file-name (concat name ".org") (symbol-value directory-var))))
    (if (file-exists-p active-file)
        (funcall orig-fn name)
      (let ((archived-file (expand-file-name
                             (concat name ".org")
                             (prilepp/archive-path (symbol-value directory-var)))))
        (if (file-exists-p archived-file)
            archived-file
          (funcall orig-fn name))))))

(dolist (registered prilepp/gtd-list-types)
  (let* ((plist (cdr registered))
         (ensure-fn (plist-get plist :ensure-fn))
         (directory-var (plist-get plist :directory-var)))
    (advice-add ensure-fn :around
                (apply-partially #'prilepp/ensure-file--check-archive directory-var)
                (list (cons 'name 'prilepp/ensure-file--check-archive)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Heading-level archiving: redirect `org-archive-subtree' per buffer

(defun prilepp/gtd-list-archive-location--maybe-set ()
  "If the current buffer visits a file under a registered GTD list type's
directory, set `org-archive-location' buffer-locally to the mirrored
archive file, creating its parent directory if missing (Org itself does
not create the archive file's directory)."
  (when buffer-file-name
    (when (seq-find
           (lambda (registered)
             (file-in-directory-p
              buffer-file-name
              (expand-file-name (symbol-value (plist-get (cdr registered) :directory-var)))))
           prilepp/gtd-list-types)
      (let ((archive-file (prilepp/archive-path buffer-file-name)))
        (make-directory (file-name-directory archive-file) t)
        (setq-local org-archive-location (concat archive-file "::"))))))

(add-hook 'find-file-hook #'prilepp/gtd-list-archive-location--maybe-set)

(provide 'init-gtd-list-archive)
;;; init-gtd-list-archive.el ends here
