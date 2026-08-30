;;; init-paths.el --- XDG directories and file locations -*- lexical-binding: t; -*-

;;; Commentary:
;; Keeps Emacs' various data/cache files out of ~/.config/emacs and
;; routed through the XDG base directories instead.

;;; Code:

(setq org-id-locations-file (expand-file-name "org-id-locations" "~/.cache/emacs/"))
(setq org-roam-db-location (expand-file-name "org-roam.db" "~/.cache/emacs/"))

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

(provide 'init-paths)
;;; init-paths.el ends here
