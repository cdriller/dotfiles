;;; init-routines.el --- Routine jumping across area-of-responsibility files -*- lexical-binding: t; -*-

;;; Commentary:
;; `prilepp/routine-find' finds a routine (a heading with a ROUTINE_ID
;; property) by name across all area-of-responsibility files under
;; `prilepp/aor-directory', jumps to it, and resets its checkboxes to
;; unchecked. If no routine matches the typed name, it inserts a new
;; routine template at point instead.

;;; Code:

(require 'init-utils)

(defun prilepp/routine--candidates ()
  "Return an alist of (HEADING-TITLE . MARKER) for every routine
(heading with a ROUTINE_ID property) under `prilepp/aor-directory'."
  (let (candidates)
    (dolist (file (directory-files (expand-file-name prilepp/aor-directory) t "\\.org\\'"))
      (with-current-buffer (find-file-noselect file)
        (org-with-wide-buffer
         (org-map-entries
          (lambda ()
            (when (org-entry-get (point) "ROUTINE_ID")
              (push (cons (org-get-heading t t t t) (point-marker)) candidates)))))))
    (nreverse candidates)))

(defun prilepp/routine-jump (marker)
  "Jump to the routine at MARKER, narrow to it, and reset its checkboxes
to unchecked."
  (switch-to-buffer (marker-buffer marker))
  (widen)
  (goto-char marker)
  (org-back-to-heading t)
  (org-show-entry)
  (org-narrow-to-subtree)
  (org-reset-checkbox-state-subtree))

(defun prilepp/routine-insert-new (name)
  "Insert a new routine template titled NAME at point."
  (insert (format "* %s\n:PROPERTIES:\n:ROUTINE_ID: %s\n:END:\n:LOGBOOK:\n:END:\n- [ ] "
                  name (prilepp/slugify name))))

(defun prilepp/routine-find ()
  "Find a routine by name across all area files and jump to it, resetting
its checkboxes to unchecked. If it doesn't exist yet, insert a new routine
template at point."
  (interactive)
  (let* ((candidates (prilepp/routine--candidates))
         (choice (completing-read "Routine: " (mapcar #'car candidates)))
         (existing (assoc choice candidates)))
    (if existing
        (prilepp/routine-jump (cdr existing))
      (prilepp/routine-insert-new choice))))

(provide 'init-routines)
;;; init-routines.el ends here
