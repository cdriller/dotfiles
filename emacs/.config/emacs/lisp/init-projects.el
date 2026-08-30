;;; init-projects.el --- Project and area-of-responsibility jumping -*- lexical-binding: t; -*-

;;; Commentary:
;; `prilepp/proj-find' and `prilepp/aor-find' let you pick a directory
;; under ~/proj/ or ~/aor/ and then act on it (open its index.org or
;; dired it). Also defines org "project:"/"area:" link types and
;; `prilepp/org-insert-project-link'/`prilepp/org-insert-area-link' to
;; link to one from anywhere.

;;; Code:

(defvar prilepp/proj-directory "~/proj/"
  "Root directory containing project folders.")

(defvar prilepp/proj-action-alist
  '((?i . prilepp/proj-open-index)
    (?d . prilepp/proj-open-dired))
  "Alist mapping action key chars to functions.
Each function receives the absolute path to the selected project directory.
Extend this list to add new `enter+KEY' actions.")

(defun prilepp/proj--list-projects ()
  "Return list of project directory names under `prilepp/proj-directory'."
  (let ((root (expand-file-name prilepp/proj-directory)))
    (seq-filter
     (lambda (f) (file-directory-p (expand-file-name f root)))
     (directory-files root nil "^[^.]"))))

(defun prilepp/proj-ensure-index (dir)
  "Ensure DIR and its index.org exist; return the index.org path."
  (let ((index (expand-file-name "index.org" dir)))
    (unless (file-exists-p index)
      (make-directory dir t)
      (with-temp-buffer (write-file index)))
    index))

(defun prilepp/proj-open-index (dir)
  "Open index.org in DIR, creating it if it doesn't exist yet."
  (find-file (prilepp/proj-ensure-index dir)))

(defun prilepp/proj-open-dired (dir)
  "Open DIR in dired, creating it first if it doesn't exist yet."
  (unless (file-directory-p dir)
    (make-directory dir t))
  (dired dir))

(defun prilepp/proj-find ()
  "Select a project under `prilepp/proj-directory', then act on it.
Typing a name that doesn't exist yet creates a new project directory.
After RET, wait for a second key press to decide the action;
see `prilepp/proj-action-alist'. Pressing RET again or C-g aborts
without doing anything."
  (interactive)
  (let* ((projects (prilepp/proj--list-projects))
         (choice (completing-read "Project: " projects))
         (dir (expand-file-name choice prilepp/proj-directory))
         (hint (mapconcat (lambda (c) (key-description (vector (car c))))
                           prilepp/proj-action-alist ", "))
         (key (read-key (format "Action for \"%s\" [%s]: " choice hint)))
         (action (alist-get key prilepp/proj-action-alist)))
    (cond
     ((memq key '(?\r ?\C-g))
      (message "Abgebrochen"))
     (action
      (funcall action dir))
     (t
      (message "No action bound to %s" (key-description (vector key)))))))

(global-set-key (kbd "C-c h p") #'prilepp/proj-find)
(which-key-add-key-based-replacements
  "C-c h p" "projects (h1)")

(defun prilepp/org-project-follow (name &optional _)
  "Follow a project link: open (or create) NAME's index.org."
  (prilepp/proj-open-index (expand-file-name name prilepp/proj-directory)))

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
  (let* ((projects (prilepp/proj--list-projects))
         (name (completing-read "Project: " projects)))
    (prilepp/proj-ensure-index (expand-file-name name prilepp/proj-directory))
    (insert (format "[[project:%s][%s]]" name name))))

(global-set-key (kbd "C-c l j") #'prilepp/org-insert-project-link)
(which-key-add-key-based-replacements
  "C-c l j" "project")

(defvar prilepp/aor-directory "~/aor/"
  "Root directory containing area-of-responsibility folders.")

(defvar prilepp/aor-action-alist
  '((?i . prilepp/aor-open-index)
    (?d . prilepp/aor-open-dired))
  "Alist mapping action key chars to functions.
Each function receives the absolute path to the selected AoR directory.
Extend this list to add new `enter+KEY' actions.")

(defun prilepp/aor--list-aors ()
  "Return list of AoR directory names under `prilepp/aor-directory'."
  (let ((root (expand-file-name prilepp/aor-directory)))
    (seq-filter
     (lambda (f) (file-directory-p (expand-file-name f root)))
     (directory-files root nil "^[^.]"))))

(defun prilepp/aor-ensure-index (dir)
  "Ensure DIR and its index.org exist; return the index.org path."
  (let ((index (expand-file-name "index.org" dir)))
    (unless (file-exists-p index)
      (make-directory dir t)
      (with-temp-buffer (write-file index)))
    index))

(defun prilepp/aor-open-index (dir)
  "Open index.org in DIR, creating it if it doesn't exist yet."
  (find-file (prilepp/aor-ensure-index dir)))

(defun prilepp/aor-open-dired (dir)
  "Open DIR in dired, creating it first if it doesn't exist yet."
  (unless (file-directory-p dir)
    (make-directory dir t))
  (dired dir))

(defun prilepp/aor-find ()
  "Select an AoR under `prilepp/aor-directory', then act on it.
Typing a name that doesn't exist yet creates a new AoR directory.
After RET, wait for a second key press to decide the action;
see `prilepp/aor-action-alist'. Pressing RET again or C-g aborts
without doing anything."
  (interactive)
  (let* ((aors (prilepp/aor--list-aors))
         (choice (completing-read "AoR: " aors))
         (dir (expand-file-name choice prilepp/aor-directory))
         (hint (mapconcat (lambda (c) (key-description (vector (car c))))
                           prilepp/aor-action-alist ", "))
         (key (read-key (format "Action for \"%s\" [%s]: " choice hint)))
         (action (alist-get key prilepp/aor-action-alist)))
    (cond
     ((memq key '(?\r ?\C-g))
      (message "Abgebrochen"))
     (action
      (funcall action dir))
     (t
      (message "No action bound to %s" (key-description (vector key)))))))

(global-set-key (kbd "C-c h a") #'prilepp/aor-find)
(which-key-add-key-based-replacements
  "C-c h a" "areas (h2)")

(defun prilepp/org-area-follow (name &optional _)
  "Follow an area link: open (or create) NAME's index.org."
  (prilepp/aor-open-index (expand-file-name name prilepp/aor-directory)))

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
  (let* ((aors (prilepp/aor--list-aors))
         (name (completing-read "Area: " aors)))
    (prilepp/aor-ensure-index (expand-file-name name prilepp/aor-directory))
    (insert (format "[[area:%s][%s]]" name name))))

(global-set-key (kbd "C-c l a") #'prilepp/org-insert-area-link)
(which-key-add-key-based-replacements
  "C-c l a" "area")

(provide 'init-projects)
;;; init-projects.el ends here
