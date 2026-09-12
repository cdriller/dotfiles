;;; init-files.el --- Shortcuts to frequently visited files -*- lexical-binding: t; -*-

;;; Commentary:
;; Quick-open commands for init.el and the GTD horizon files in
;; ~/notes/horizons/, plus a helper to link to an org heading.

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

(global-set-key (kbd "C-c s") #'my/edit-someday-file)
(which-key-add-key-based-replacements
  "C-c s" "someday")

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
;; GTD horizons of focus

(defvar prilepp/actions-directory "~/notes/horizons/actions/"
  "Directory containing one org file per GTD context (horizon 0).")

(defun prilepp/actions--list-contexts ()
  "Return the context names (without .org) under `prilepp/actions-directory'."
  (let ((root (expand-file-name prilepp/actions-directory)))
    (when (file-directory-p root)
      (mapcar #'file-name-sans-extension
              (directory-files root nil "\\.org\\'")))))

(defun prilepp/actions-ensure-file (name)
  "Ensure NAME's context file exists under `prilepp/actions-directory'; return its path."
  (let ((file (expand-file-name (concat name ".org") prilepp/actions-directory)))
    (unless (file-exists-p file)
      (make-directory prilepp/actions-directory t)
      (with-temp-buffer
        (insert "#+TODO: TODO(t) WAITING(w) | DONE(d)\n\n")
        (write-file file)))
    file))

(defun prilepp/actions-find ()
  "Select a context under `prilepp/actions-directory' and open it,
creating a new context file if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Context: " (prilepp/actions--list-contexts))))
    (find-file (prilepp/actions-ensure-file name))))

(setq org-agenda-custom-commands
      '(("d" "Deadlines (Actions)" agenda ""
         ((org-agenda-files (directory-files (expand-file-name prilepp/actions-directory) t "\\.org\\'"))
          (org-agenda-entry-types '(:deadline))
          (org-agenda-span 'month)))))

(defun prilepp/agenda-deadlines ()
  "Show all deadlines set in `prilepp/actions-directory'."
  (interactive)
  (org-agenda nil "d"))

(global-set-key (kbd "C-c v d") #'prilepp/agenda-deadlines)
(which-key-add-key-based-replacements
  "C-c v d" "deadlines")

(defun prilepp/action-move-to-context ()
  "Move the action (subtree) at point to another context file under
`prilepp/actions-directory', creating the context if it doesn't exist yet."
  (interactive)
  (let* ((current (buffer-file-name))
         (choice (completing-read "Move to context: " (prilepp/actions--list-contexts)))
         (target (prilepp/actions-ensure-file choice)))
    (when (and current (equal (expand-file-name target) (expand-file-name current)))
      (user-error "Already in context \"%s\"" choice))
    (org-cut-subtree)
    (save-buffer)
    (with-current-buffer (find-file-noselect target)
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (org-paste-subtree 1)
      (save-buffer))
    (message "Moved to \"%s\"" choice)))

(global-set-key (kbd "C-c m") #'prilepp/action-move-to-context)
(which-key-add-key-based-replacements
  "C-c m" "move to context")

(defvar prilepp/agendas-directory "~/notes/agendas/"
  "Directory containing one org file per GTD agenda (person/meeting).")

(defun prilepp/agendas--list-entries ()
  "Return the agenda names (without .org) under `prilepp/agendas-directory'."
  (let ((root (expand-file-name prilepp/agendas-directory)))
    (when (file-directory-p root)
      (mapcar #'file-name-sans-extension
              (directory-files root nil "\\.org\\'")))))

(defun prilepp/agendas-ensure-file (name)
  "Ensure NAME's agenda file exists under `prilepp/agendas-directory'; return its path."
  (let ((file (expand-file-name (concat name ".org") prilepp/agendas-directory)))
    (unless (file-exists-p file)
      (make-directory prilepp/agendas-directory t)
      (with-temp-buffer (write-file file)))
    file))

(defun prilepp/agendas-find ()
  "Select an agenda under `prilepp/agendas-directory' and open it,
creating a new agenda file if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Agenda: " (prilepp/agendas--list-entries))))
    (find-file (prilepp/agendas-ensure-file name))))

(defun my/insert-link-to-org-heading ()
  "Search headings across `org-refile-targets` and insert a link to the selected one."
  (interactive)
  (let* ((target (org-refile-get-location "Link zu Überschrift: "))
         (file (nth 1 target))
         (pos (nth 3 target))
         id desc)
    (with-current-buffer (find-file-noselect file)
      (save-excursion
        (goto-char pos)
        (setq id (org-id-get-create))
        (setq desc (org-get-heading t t t t))))
    (insert (format "[[id:%s][%s]]" id desc))))

(global-set-key (kbd "C-c i h") #'my/insert-link-to-org-heading)
(which-key-add-key-based-replacements
  "C-c i h" "heading")

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
