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

(prilepp/define-horizon-type actions
  :directory "~/notes/horizons/actions/"
  :list-fn prilepp/actions--list-contexts
  :find-fn prilepp/actions-find
  :find-prompt "Context: "
  :ensure-fn prilepp/actions-ensure-file
  :default-content "#+TODO: TODO(t) WAITING(w) | DONE(d)\n\n"
  :link-word nil)

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

(setq org-agenda-custom-commands
      '(("d" "Deadlines (Actions)" agenda ""
         ((org-agenda-files (directory-files (expand-file-name prilepp/actions-directory) t "\\.org\\'"))
          (org-agenda-entry-types '(:deadline))
          (org-agenda-span 'month)))
        ("t" "Tickler" agenda ""
         ((org-agenda-files (list (prilepp/tickler-ensure-file)))
          (org-agenda-entry-types '(:scheduled))
          (org-agenda-span 'day)
          (org-agenda-skip-scheduled-if-done t)))))

(defun prilepp/agenda-deadlines ()
  "Show all deadlines set in `prilepp/actions-directory'."
  (interactive)
  (org-agenda nil "d"))

(global-set-key (kbd "C-c v d") #'prilepp/agenda-deadlines)
(which-key-add-key-based-replacements
  "C-c v d" "deadlines")

(defun prilepp/agenda-tickler ()
  "Show tickler items in `prilepp/tickler-file' due today or earlier."
  (interactive)
  (org-agenda nil "t"))

(global-set-key (kbd "C-c v t") #'prilepp/agenda-tickler)
(which-key-add-key-based-replacements
  "C-c v t" "tickler")

(defun prilepp/action-move-to-context ()
  "Move the action (subtree) at point to another context file under
`prilepp/actions-directory', creating the context if it doesn't exist yet."
  (interactive)
  (let* ((current (buffer-file-name))
         (entries (prilepp/horizon-entries 'actions))
         (choice (prilepp/horizon-entry-name
                  (completing-read "Move to context: " (mapcar #'car entries))
                  entries))
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
