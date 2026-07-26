(load-theme 'modus-vivendi t)
(tool-bar-mode -1)
(setq create-lockfiles nil)

(setq org-id-locations-file (expand-file-name "org-id-locations" "~/.cache/emacs/"))
(setq org-roam-db-location (expand-file-name "org-roam.db" "~/.cache/emacs/"))

(setq mac-option-modifier 'meta
      mac-right-option-modifier 'none)
;
(setq vc-follow-symlinks t)

; do not truncate lines
(global-visual-line-mode 1)

(use-package emacs
  :ensure nil
  :bind (("M-h" . windmove-left)
         ("M-j" . windmove-down)
         ("M-k" . windmove-up)
         ("M-l" . windmove-right)))

(defun my/edit-init-file ()
  "Open the Emacs init file."
  (interactive)
  (find-file user-init-file))

(global-set-key (kbd "C-c e") #'my/edit-init-file)

(defun my/edit-project-file ()
  "Open project file."
  (interactive)
  (find-file "~/plan/projects.org"))

(global-set-key (kbd "C-c p p") #'my/edit-project-file)

(defun my/edit-someday-file ()
  "Open someday file."
  (interactive)
  (find-file "~/plan/someday.org"))

(global-set-key (kbd "C-c p s") #'my/edit-someday-file)

(defun my/edit-areas-file ()
  "Open areas file."
  (interactive)
  (find-file "~/plan/areas.org"))

(global-set-key (kbd "C-c p a") #'my/edit-areas-file)

(defun my/edit-goals-file ()
  "Open areas file."
  (interactive)
  (find-file "~/plan/goals.org"))

(global-set-key (kbd "C-c p g") #'my/edit-goals-file)

(defun my/edit-life-file ()
  "Open life file."
  (interactive)
  (find-file "~/plan/life.org"))

(global-set-key (kbd "C-c p l") #'my/edit-life-file)

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

(global-set-key (kbd "C-c l h") #'my/insert-link-to-org-heading)
;; XDG directories
(defvar my/xdg-cache  (getenv "XDG_CACHE_HOME"))
(defvar my/xdg-data   (getenv "XDG_DATA_HOME"))
(defvar my/xdg-state  (getenv "XDG_STATE_HOME"))

;; Package storage → XDG_DATA_HOME
(setq package-user-dir
      (expand-file-name "emacs/packages" my/xdg-data))

;; Auto-save → XDG_CACHE_HOME
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "emacs/auto-save/" my/xdg-cache) t)))

;; Backup → XDG_CACHE_HOME
(setq backup-directory-alist
      `((".*" . ,(expand-file-name "emacs/backup/" my/xdg-cache))))

;; Undo history → XDG_STATE_HOME
(setq undo-tree-history-directory-alist
      `((".*" . ,(expand-file-name "emacs/undo/" my/xdg-state))))

;; Recentf → XDG_CACHE_HOME
(setq recentf-save-file
      (expand-file-name "emacs/recentf" my/xdg-cache))

;; Bookmarks → XDG_DATA_HOME
(setq bookmark-default-file
      (expand-file-name "emacs/bookmarks" my/xdg-data))

(setq transient-history-file
      (expand-file-name "emacs/transient/history.el" (getenv "XDG_DATA_HOME")))

;; Custom file (keeps customize clutter out of init.el)
(setq custom-file
      (expand-file-name "emacs/custom.el" my/xdg-data))
(load custom-file :noerror)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bootstrap package manager
(setq package-install-upgrade-built-in t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Install use-package if not present
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)  ; auto-install all packages

(defun my/org-plan-files ()
  "Return all .org files in the plan directory."
  (directory-files "~/plan/" t "\\.org\\'"))


(use-package org
  :ensure nil
  :init
  (setq org-id-link-to-org-use-id t)
  (setq org-refile-targets
      '((my/org-plan-files :maxlevel . 3)))
  )

(use-package org-roam
  :custom
  (org-roam-directory (expand-file-name "notes" (getenv "HOME")))
  :bind
  (("C-c n p" . org-roam-node-find)
   ("C-c l p" . org-roam-node-insert)
   ("C-c n b" . org-roam-buffer-toggle))
  :init
  (which-key-add-key-based-replacements
    "C-c n p" "find or create permanent node"
    "C-c l p" "insert link to permanent node "
    "C-c n b" "show backlinks")
  :config
  (org-roam-db-autosync-mode))

(use-package org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(use-package vertico
  :config
  (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :ensure t
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)))

(use-package citar
  :custom
  (citar-bibliography '("~/.local/share/bib-exports/My Library.bib"))
  ;; Ordner, in dem du deine annotierten PDFs ablegst:
  (citar-library-paths '("~/media/books/"))
  ;; Notizen liegen im org-roam-Verzeichnis:
  (citar-notes-paths (list (expand-file-name "notes" (getenv "HOME"))))
  :bind
  (("C-c n l" . citar-open-notes)
   ("C-c l l" . citar-insert-citation))
   :init
   (which-key-add-key-based-replacements
     "C-c n l" "find or create literature node"
     "C-c l l" "insert link to literature node"))

(use-package citar-org-roam
  :after (citar org-roam)
  :config
  (citar-org-roam-mode)
  :custom
  ;; Notes bekommen einen sinnvollen Titel aus den Bib-Daten:
  (citar-org-roam-note-title-template "${author} - ${title}"))

;; org-cite so einstellen, dass Insert/Follow über citar läuft:
(use-package oc
  :ensure nil           ; ist Teil von Org, nicht extra installieren
  :custom
  (org-cite-global-bibliography '("~/org/bib/library.bib"))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar))

(use-package which-key
  :ensure nil
  :config
  (which-key-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project directory jumping

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

(defun prilepp/proj-open-index (dir)
  "Open index.org in DIR, creating it if it doesn't exist yet."
  (let ((index (expand-file-name "index.org" dir)))
    (unless (file-exists-p index)
      (make-directory dir t)
      (with-temp-buffer (write-file index)))
    (find-file index)))

(defun prilepp/proj-open-dired (dir)
  "Open DIR in dired."
  (dired dir))

(defun prilepp/proj-find ()
  "Select a project under `prilepp/proj-directory', then act on it.
After RET, wait for a second key press to decide the action;
see `prilepp/proj-action-alist'. Pressing RET again or C-g aborts
without doing anything."
  (interactive)
  (let* ((projects (prilepp/proj--list-projects))
         (choice (completing-read "Project: " projects nil t))
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

(global-set-key (kbd "C-c p f") #'prilepp/proj-find)
(which-key-add-key-based-replacements
  "C-c p f" "find project")
