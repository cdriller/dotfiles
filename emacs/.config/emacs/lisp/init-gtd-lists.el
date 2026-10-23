;;; init-gtd-lists.el --- All GTD list-type declarations: Action, Project, Area, Goal, Vision, Life, Agenda -*- lexical-binding: t; -*-

;;; Commentary:
;; All seven GTD list-type declarations: Action, Project, Area, Goal,
;; Vision, Life, Agenda. Each is defined via
;; `prilepp/define-gtd-list-type' (see init-gtd-list-types.el) instead
;; of by hand. Also holds the Actions-specific deadlines agenda view
;; and move-to-context command, since they're coupled to the Actions
;; declaration.

;;; Code:

(prilepp/define-gtd-list-type actions
  :directory "~/notes/horizons/actions/"
  :list-fn prilepp/actions--list-contexts
  :find-fn prilepp/actions-find
  :find-prompt "Context: "
  :ensure-fn prilepp/actions-ensure-file
  :default-content "#+TODO: TODO(t) WAITING(w) | DONE(d)\n\n"
  :link-word nil)

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

(defun prilepp/action-move-to-context ()
  "Move the action (subtree) at point to another context file under
`prilepp/actions-directory', creating the context if it doesn't exist yet."
  (interactive)
  (let* ((current (buffer-file-name))
         (entries (prilepp/gtd-list-entries 'actions))
         (choice (prilepp/gtd-list-entry-name
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

(prilepp/define-gtd-list-type proj
  :directory "~/notes/horizons/proj/"
  :list-fn prilepp/proj--list-projects
  :find-fn prilepp/proj-find
  :find-prompt "Project: "
  :ensure-fn prilepp/proj-ensure-file
  :default-content "#+TODO: TODO(t) WAITING(w) | DONE(d)\n\n* TODO %s\n"
  :link-word "project"
  :link-follow-fn prilepp/org-project-follow
  :link-complete-fn prilepp/org-project-complete
  :insert-fn prilepp/org-insert-project-link
  :insert-prompt "Project: ")

(prilepp/define-gtd-list-type aor
  :directory "~/notes/horizons/aor/"
  :list-fn prilepp/aor--list-aors
  :find-fn prilepp/aor-find
  :find-prompt "AoR: "
  :ensure-fn prilepp/aor-ensure-file
  :default-content nil
  :link-word "area"
  :link-follow-fn prilepp/org-area-follow
  :link-complete-fn prilepp/org-area-complete
  :insert-fn prilepp/org-insert-area-link
  :insert-prompt "Area: ")

(prilepp/define-gtd-list-type life
  :directory "~/notes/horizons/life/"
  :list-fn prilepp/life--list-entries
  :find-fn prilepp/life-find
  :find-prompt "Life: "
  :ensure-fn prilepp/life-ensure-file
  :default-content nil
  :link-word "life"
  :link-follow-fn prilepp/org-life-follow
  :link-complete-fn prilepp/org-life-complete
  :insert-fn prilepp/org-insert-life-link
  :insert-prompt "Life: ")

(prilepp/define-gtd-list-type goals
  :directory "~/notes/horizons/goals/"
  :list-fn prilepp/goals--list-entries
  :find-fn prilepp/goals-find
  :find-prompt "Goal: "
  :ensure-fn prilepp/goals-ensure-file
  :default-content nil
  :link-word "goal"
  :link-follow-fn prilepp/org-goal-follow
  :link-complete-fn prilepp/org-goal-complete
  :insert-fn prilepp/org-insert-goal-link
  :insert-prompt "Goal: ")

(prilepp/define-gtd-list-type vision
  :directory "~/notes/horizons/vision/"
  :list-fn prilepp/vision--list-entries
  :find-fn prilepp/vision-find
  :find-prompt "Vision: "
  :ensure-fn prilepp/vision-ensure-file
  :default-content nil
  :link-word "vision"
  :link-follow-fn prilepp/org-vision-follow
  :link-complete-fn prilepp/org-vision-complete
  :insert-fn prilepp/org-insert-vision-link
  :insert-prompt "Vision: ")

(prilepp/define-gtd-list-type agendas
  :directory "~/notes/agendas/"
  :list-fn prilepp/agendas--list-entries
  :find-fn prilepp/agendas-find
  :find-prompt "Agenda: "
  :ensure-fn prilepp/agendas-ensure-file
  :default-content nil
  :link-word nil)

(provide 'init-gtd-lists)
;;; init-gtd-lists.el ends here
