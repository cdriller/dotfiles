;;; init-projects.el --- Project and area-of-responsibility jumping -*- lexical-binding: t; -*-

;;; Commentary:
;; `prilepp/proj-find', `prilepp/aor-find', `prilepp/life-find',
;; `prilepp/goals-find', and `prilepp/vision-find' each find-or-create a
;; single org file per project/area/life-entry/goal/vision-item under
;; ~/notes/horizons/proj/, ~/notes/horizons/aor/, ~/notes/horizons/life/,
;; ~/notes/horizons/goals/, and ~/notes/horizons/vision/. Also defines org
;; "project:"/"area:"/"life:"/"goal:"/"vision:" link types and
;; `prilepp/org-insert-project-link'/`prilepp/org-insert-area-link'/
;; `prilepp/org-insert-life-link'/`prilepp/org-insert-goal-link'/
;; `prilepp/org-insert-vision-link' to link to one from anywhere.
;;
;; Each of the five types below is defined via
;; `prilepp/define-horizon-type' (see init-horizon-types.el) instead of
;; by hand.

;;; Code:

(prilepp/define-horizon-type proj
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

(prilepp/define-horizon-type aor
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

(prilepp/define-horizon-type life
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

(prilepp/define-horizon-type goals
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

(prilepp/define-horizon-type vision
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

(provide 'init-projects)
;;; init-projects.el ends here
