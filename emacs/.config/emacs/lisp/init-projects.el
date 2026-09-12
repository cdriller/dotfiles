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

;;; Code:

(defvar prilepp/proj-directory "~/notes/horizons/proj/"
  "Directory containing one org file per project.")

(defun prilepp/proj--list-projects ()
  "Return the project names (without .org) under `prilepp/proj-directory'."
  (let ((root (expand-file-name prilepp/proj-directory)))
    (when (file-directory-p root)
      (mapcar #'file-name-sans-extension
              (directory-files root nil "\\.org\\'")))))

(defun prilepp/proj-ensure-file (name)
  "Ensure NAME's project file exists under `prilepp/proj-directory'; return its path."
  (let ((file (expand-file-name (concat name ".org") prilepp/proj-directory)))
    (unless (file-exists-p file)
      (make-directory prilepp/proj-directory t)
      (with-temp-buffer
        (insert (format "#+TODO: TODO(t) WAITING(w) | DONE(d)\n\n* TODO %s\n" name))
        (write-file file)))
    file))

(defun prilepp/proj-find ()
  "Select a project under `prilepp/proj-directory' and open it,
creating a new project file if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Project: " (prilepp/proj--list-projects))))
    (find-file (prilepp/proj-ensure-file name))))

(defun prilepp/org-project-follow (name &optional _)
  "Follow a project link: open (or create) NAME's project file."
  (find-file (prilepp/proj-ensure-file name)))

(defun prilepp/org-project-complete (&optional _)
  "Interactively select a project for `org-insert-link' (C-c C-l)."
  (concat "project:" (completing-read "Project: " (prilepp/proj--list-projects))))

(with-eval-after-load 'org
  (org-link-set-parameters "project"
                            :follow #'prilepp/org-project-follow
                            :complete #'prilepp/org-project-complete))

(defun prilepp/org-insert-project-link ()
  "Select a project and insert `[[project:NAME][NAME]]' at point,
creating the project if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Project: " (prilepp/proj--list-projects))))
    (prilepp/proj-ensure-file name)
    (insert (format "[[project:%s][%s]]" name name))))

(global-set-key (kbd "C-c i j") #'prilepp/org-insert-project-link)
(which-key-add-key-based-replacements
  "C-c i j" "project")

(defvar prilepp/aor-directory "~/notes/horizons/aor/"
  "Directory containing one org file per area of responsibility.")

(defun prilepp/aor--list-aors ()
  "Return the AoR names (without .org) under `prilepp/aor-directory'."
  (let ((root (expand-file-name prilepp/aor-directory)))
    (when (file-directory-p root)
      (mapcar #'file-name-sans-extension
              (directory-files root nil "\\.org\\'")))))

(defun prilepp/aor-ensure-file (name)
  "Ensure NAME's AoR file exists under `prilepp/aor-directory'; return its path."
  (let ((file (expand-file-name (concat name ".org") prilepp/aor-directory)))
    (unless (file-exists-p file)
      (make-directory prilepp/aor-directory t)
      (with-temp-buffer (write-file file)))
    file))

(defun prilepp/aor-find ()
  "Select an AoR under `prilepp/aor-directory' and open it,
creating a new AoR file if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "AoR: " (prilepp/aor--list-aors))))
    (find-file (prilepp/aor-ensure-file name))))

(defun prilepp/org-area-follow (name &optional _)
  "Follow an area link: open (or create) NAME's AoR file."
  (find-file (prilepp/aor-ensure-file name)))

(defun prilepp/org-area-complete (&optional _)
  "Interactively select an AoR for `org-insert-link' (C-c C-l)."
  (concat "area:" (completing-read "Area: " (prilepp/aor--list-aors))))

(with-eval-after-load 'org
  (org-link-set-parameters "area"
                            :follow #'prilepp/org-area-follow
                            :complete #'prilepp/org-area-complete))

(defun prilepp/org-insert-area-link ()
  "Select an area and insert `[[area:NAME][NAME]]' at point,
creating the area if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Area: " (prilepp/aor--list-aors))))
    (prilepp/aor-ensure-file name)
    (insert (format "[[area:%s][%s]]" name name))))

(global-set-key (kbd "C-c i a") #'prilepp/org-insert-area-link)
(which-key-add-key-based-replacements
  "C-c i a" "area")

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

(defvar prilepp/life-directory "~/notes/horizons/life/"
  "Directory containing one org file per life-horizon entry.")

(defun prilepp/life--list-entries ()
  "Return the entry names (without .org) under `prilepp/life-directory'."
  (let ((root (expand-file-name prilepp/life-directory)))
    (when (file-directory-p root)
      (mapcar #'file-name-sans-extension
              (directory-files root nil "\\.org\\'")))))

(defun prilepp/life-ensure-file (name)
  "Ensure NAME's life-horizon file exists under `prilepp/life-directory'; return its path."
  (let ((file (expand-file-name (concat name ".org") prilepp/life-directory)))
    (unless (file-exists-p file)
      (make-directory prilepp/life-directory t)
      (with-temp-buffer (write-file file)))
    file))

(defun prilepp/life-find ()
  "Select a life-horizon entry under `prilepp/life-directory' and open it,
creating a new entry file if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Life: " (prilepp/life--list-entries))))
    (find-file (prilepp/life-ensure-file name))))

(defun prilepp/org-life-follow (name &optional _)
  "Follow a life link: open (or create) NAME's life-horizon file."
  (find-file (prilepp/life-ensure-file name)))

(defun prilepp/org-life-complete (&optional _)
  "Interactively select a life-horizon entry for `org-insert-link' (C-c C-l)."
  (concat "life:" (completing-read "Life: " (prilepp/life--list-entries))))

(with-eval-after-load 'org
  (org-link-set-parameters "life"
                            :follow #'prilepp/org-life-follow
                            :complete #'prilepp/org-life-complete))

(defun prilepp/org-insert-life-link ()
  "Select a life-horizon entry and insert `[[life:NAME][NAME]]' at point,
creating the entry if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Life: " (prilepp/life--list-entries))))
    (prilepp/life-ensure-file name)
    (insert (format "[[life:%s][%s]]" name name))))

(global-set-key (kbd "C-c i i") #'prilepp/org-insert-life-link)
(which-key-add-key-based-replacements
  "C-c i i" "life")

(defvar prilepp/goals-directory "~/notes/horizons/goals/"
  "Directory containing one org file per goal.")

(defun prilepp/goals--list-entries ()
  "Return the goal names (without .org) under `prilepp/goals-directory'."
  (let ((root (expand-file-name prilepp/goals-directory)))
    (when (file-directory-p root)
      (mapcar #'file-name-sans-extension
              (directory-files root nil "\\.org\\'")))))

(defun prilepp/goals-ensure-file (name)
  "Ensure NAME's goal file exists under `prilepp/goals-directory'; return its path."
  (let ((file (expand-file-name (concat name ".org") prilepp/goals-directory)))
    (unless (file-exists-p file)
      (make-directory prilepp/goals-directory t)
      (with-temp-buffer (write-file file)))
    file))

(defun prilepp/goals-find ()
  "Select a goal under `prilepp/goals-directory' and open it,
creating a new goal file if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Goal: " (prilepp/goals--list-entries))))
    (find-file (prilepp/goals-ensure-file name))))

(defun prilepp/org-goal-follow (name &optional _)
  "Follow a goal link: open (or create) NAME's goal file."
  (find-file (prilepp/goals-ensure-file name)))

(defun prilepp/org-goal-complete (&optional _)
  "Interactively select a goal for `org-insert-link' (C-c C-l)."
  (concat "goal:" (completing-read "Goal: " (prilepp/goals--list-entries))))

(with-eval-after-load 'org
  (org-link-set-parameters "goal"
                            :follow #'prilepp/org-goal-follow
                            :complete #'prilepp/org-goal-complete))

(defun prilepp/org-insert-goal-link ()
  "Select a goal and insert `[[goal:NAME][NAME]]' at point,
creating the goal if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Goal: " (prilepp/goals--list-entries))))
    (prilepp/goals-ensure-file name)
    (insert (format "[[goal:%s][%s]]" name name))))

(global-set-key (kbd "C-c i g") #'prilepp/org-insert-goal-link)
(which-key-add-key-based-replacements
  "C-c i g" "goal")

(defvar prilepp/vision-directory "~/notes/horizons/vision/"
  "Directory containing one org file per vision item.")

(defun prilepp/vision--list-entries ()
  "Return the vision-item names (without .org) under `prilepp/vision-directory'."
  (let ((root (expand-file-name prilepp/vision-directory)))
    (when (file-directory-p root)
      (mapcar #'file-name-sans-extension
              (directory-files root nil "\\.org\\'")))))

(defun prilepp/vision-ensure-file (name)
  "Ensure NAME's vision file exists under `prilepp/vision-directory'; return its path."
  (let ((file (expand-file-name (concat name ".org") prilepp/vision-directory)))
    (unless (file-exists-p file)
      (make-directory prilepp/vision-directory t)
      (with-temp-buffer (write-file file)))
    file))

(defun prilepp/vision-find ()
  "Select a vision item under `prilepp/vision-directory' and open it,
creating a new vision file if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Vision: " (prilepp/vision--list-entries))))
    (find-file (prilepp/vision-ensure-file name))))

(defun prilepp/org-vision-follow (name &optional _)
  "Follow a vision link: open (or create) NAME's vision file."
  (find-file (prilepp/vision-ensure-file name)))

(defun prilepp/org-vision-complete (&optional _)
  "Interactively select a vision item for `org-insert-link' (C-c C-l)."
  (concat "vision:" (completing-read "Vision: " (prilepp/vision--list-entries))))

(with-eval-after-load 'org
  (org-link-set-parameters "vision"
                            :follow #'prilepp/org-vision-follow
                            :complete #'prilepp/org-vision-complete))

(defun prilepp/org-insert-vision-link ()
  "Select a vision item and insert `[[vision:NAME][NAME]]' at point,
creating the vision item if it doesn't exist yet."
  (interactive)
  (let ((name (completing-read "Vision: " (prilepp/vision--list-entries))))
    (prilepp/vision-ensure-file name)
    (insert (format "[[vision:%s][%s]]" name name))))

(global-set-key (kbd "C-c i v") #'prilepp/org-insert-vision-link)
(which-key-add-key-based-replacements
  "C-c i v" "vision")

(provide 'init-projects)
;;; init-projects.el ends here
