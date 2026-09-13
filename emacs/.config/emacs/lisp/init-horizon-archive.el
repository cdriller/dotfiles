;;; init-horizon-archive.el --- Archive/restore for GTD horizon types -*- lexical-binding: t; -*-

;;; Commentary:
;; Generic archive/restore support for every horizon type registered in
;; `prilepp/horizon-types' (see init-horizon-types.el): a path-mirroring
;; rule between ~/notes/... and ~/notes/archive/..., the interactive
;; `prilepp/archive-entry'/`prilepp/restore-entry' commands, a fix so
;; that following a link to an archived entry opens the archived file
;; instead of silently recreating an empty active one, and a
;; `find-file-hook' that redirects Org's built-in subtree archiving
;; (`C-c C-x C-a') into the mirrored archive file for horizon-type
;; buffers. Loaded after init-projects/init-files so the registry is
;; fully populated first. See design.md in the
;; "emacs-horizons-archive-functionality" change for the full rationale.

;;; Code:

(require 'init-horizon-types)

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

(defun prilepp/horizon-archived-names (slug)
  "Return the archived entry names (without .org) for horizon-type SLUG,
or nil if that type has no archive directory yet."
  (let* ((directory-var (plist-get (alist-get slug prilepp/horizon-types) :directory-var))
         (root (prilepp/archive-path (expand-file-name (symbol-value directory-var)))))
    (when (file-directory-p root)
      (mapcar #'file-name-sans-extension
              (directory-files root nil "\\.org\\'")))))

(defun prilepp/horizon-type--prompt (prompt)
  "Read a registered horizon-type slug with PROMPT; return its registry entry."
  (let ((slug (intern (completing-read
                        prompt
                        (mapcar #'symbol-name (mapcar #'car prilepp/horizon-types))
                        nil t))))
    (alist-get slug prilepp/horizon-types)))

(defun prilepp/horizon--move-file (old-path new-path)
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
  "Archive an existing horizon entry: prompt for its type, then an
existing active entry of that type, and move its file to the mirrored
archive path."
  (interactive)
  (let* ((entry (prilepp/horizon-type--prompt "Archive type: "))
         (list-fn (plist-get entry :list-fn))
         (directory-var (plist-get entry :directory-var))
         (name (completing-read "Archive entry: " (funcall list-fn) nil t))
         (active-path (expand-file-name (concat name ".org") (symbol-value directory-var)))
         (archive-path (prilepp/archive-path active-path)))
    (prilepp/horizon--move-file active-path archive-path)
    (message "Archived \"%s\"" name)))

(defun prilepp/restore-entry ()
  "Restore an archived horizon entry: prompt for its type, then an
existing archived entry of that type, and move its file back to the
mirrored active path."
  (interactive)
  (let* ((entry (prilepp/horizon-type--prompt "Restore type: "))
         (slug (plist-get entry :slug))
         (directory-var (plist-get entry :directory-var))
         (name (completing-read "Restore entry: " (prilepp/horizon-archived-names slug) nil t))
         (archive-path (expand-file-name
                         (concat name ".org")
                         (prilepp/archive-path (symbol-value directory-var))))
         (active-path (prilepp/active-path archive-path)))
    (prilepp/horizon--move-file archive-path active-path)
    (message "Restored \"%s\"" name)))

(global-set-key (kbd "C-c a a") #'prilepp/archive-entry)
(global-set-key (kbd "C-c a r") #'prilepp/restore-entry)
(which-key-add-key-based-replacements
  "C-c a" "archive")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Stale-link fix: resolve archived entries instead of recreating them

(defun prilepp/ensure-file--check-archive (directory-var orig-fn name)
  "Around-advice for a horizon type's ensure-fn (whose directory variable
is DIRECTORY-VAR): if NAME exists in the mirrored archive directory,
return that archived path directly instead of calling ORIG-FN (which
would otherwise create a new empty active file); otherwise call ORIG-FN
unchanged."
  (let ((archived-file (expand-file-name
                         (concat name ".org")
                         (prilepp/archive-path (symbol-value directory-var)))))
    (if (file-exists-p archived-file)
        archived-file
      (funcall orig-fn name))))

(dolist (registered prilepp/horizon-types)
  (let* ((plist (cdr registered))
         (ensure-fn (plist-get plist :ensure-fn))
         (directory-var (plist-get plist :directory-var)))
    (advice-add ensure-fn :around
                (apply-partially #'prilepp/ensure-file--check-archive directory-var)
                (list (cons 'name 'prilepp/ensure-file--check-archive)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Heading-level archiving: redirect `org-archive-subtree' per buffer

(defun prilepp/horizon-archive-location--maybe-set ()
  "If the current buffer visits a file under a registered horizon type's
directory, set `org-archive-location' buffer-locally to the mirrored
archive file, creating its parent directory if missing (Org itself does
not create the archive file's directory)."
  (when buffer-file-name
    (when (seq-find
           (lambda (registered)
             (file-in-directory-p
              buffer-file-name
              (expand-file-name (symbol-value (plist-get (cdr registered) :directory-var)))))
           prilepp/horizon-types)
      (let ((archive-file (prilepp/archive-path buffer-file-name)))
        (make-directory (file-name-directory archive-file) t)
        (setq-local org-archive-location (concat archive-file "::"))))))

(add-hook 'find-file-hook #'prilepp/horizon-archive-location--maybe-set)

(provide 'init-horizon-archive)
;;; init-horizon-archive.el ends here
