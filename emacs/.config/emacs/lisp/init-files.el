;;; init-files.el --- Shortcuts to frequently visited files -*- lexical-binding: t; -*-

;;; Commentary:
;; Quick-open commands for init.el, the journal, and the someday file,
;; plus a helper to link to an org heading via a "heading:" link type.

;;; Code:

(defun my/edit-init-file ()
  "Open the Emacs init file."
  (interactive)
  (find-file user-init-file))

(global-set-key (kbd "C-c e") #'my/edit-init-file)

(defun my/edit-someday-file ()
  "Open someday file."
  (interactive)
  (find-file "~/notes/someday.org"))

(defvar prilepp/journal-directory "~/notes/journal/"
  "Directory containing one org file per day.")

(defun prilepp/journal-today ()
  "Open (or create) today's journal entry in `prilepp/journal-directory'."
  (interactive)
  (let* ((dir (expand-file-name prilepp/journal-directory))
         (file (expand-file-name
                (format-time-string "%Y-%m-%d.org")
                dir)))
    (unless (file-exists-p file)
      (make-directory dir t)
      (with-temp-buffer (write-file file)))
    (find-file file)))

(global-set-key (kbd "C-c j") #'prilepp/journal-today)
(which-key-add-key-based-replacements
  "C-c j" "journal")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tickler

(defvar prilepp/tickler-file "~/notes/tickler.org"
  "Path to the tickler file: a flat Org file of date-deferred reminders.")

(defun prilepp/tickler-ensure-file ()
  "Ensure `prilepp/tickler-file' exists, seeded with a #+TODO line.
Return its expanded path."
  (let ((file (expand-file-name prilepp/tickler-file)))
    (unless (file-exists-p file)
      (with-temp-buffer
        (insert "#+TODO: TODO(t) | DONE(d)\n")
        (write-file file)))
    file))

(defun prilepp/agenda-tickler ()
  "Show tickler items in `prilepp/tickler-file' due today or earlier."
  (interactive)
  (org-agenda nil "t"))

(global-set-key (kbd "C-c v t") #'prilepp/agenda-tickler)
(which-key-add-key-based-replacements
  "C-c v t" "tickler")

(defun prilepp/org-heading-complete (&optional _)
  "Select a heading via org-refile-targets for `org-insert-link' (C-c C-l);
returns an id: link."
  (let* ((target (org-refile-get-location "Heading: "))
         (file (nth 1 target))
         (pos (nth 3 target))
         id)
    (with-current-buffer (find-file-noselect file)
      (save-excursion (goto-char pos) (setq id (org-id-get-create))))
    (concat "id:" id)))

(with-eval-after-load 'org
  (org-link-set-parameters "heading" :complete #'prilepp/org-heading-complete))

(provide 'init-files)
;;; init-files.el ends here
