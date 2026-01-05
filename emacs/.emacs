;; -*- mode: elisp -*-
;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
; (package-initialize)
; (package-refresh-contents)

;; Download Evil
(unless (package-installed-p 'evil)
  (package-install 'evil))

;; Enable Evil
(require 'evil)
(evil-mode 1)

; evil spc, ret and tab do not any usefull that's why disable it so less important
; keybindings fire
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))

;; Disable the splash screen (to enable it agin, replace the t with 0)
(setq inhibit-splash-screen t)

;; Enable transient mark mode
(transient-mark-mode 1)
(tool-bar-mode -1)
(menu-bar-mode -1)

(global-set-key (kbd "M-l") 'windmove-right)
(global-set-key (kbd "M-h") 'windmove-left) ; TODO: gets overriden by org mode maps, has to be loaded later
(global-set-key (kbd "M-k") 'windmove-up)
(global-set-key (kbd "M-j") 'windmove-down)

(global-set-key (kbd "M-a") 'org-agenda)
(global-set-key (kbd "M-c") 'org-capture)

;;;; Helm configuration
(unless (package-installed-p 'helm)
  (package-install 'helm))
(require 'helm)
(helm-mode 1) ; facultative.
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-f") 'helm-find-files)

;;;;Org mode configuration
(setq org-directory "~/org/")
(setq org-default-notes-file (concat org-directory "/inbox.org"))
(setq org-capture-templates
      '(("t" "Todo" entry (file org-default-notes-file)
         "* TODO %?\n  %i\n  %a")))
; source - https://stackoverflow.com/a
; Posted by Mingwei Zhang, modified by community. See post 'Timeline' for change history
; Retrieved 2026-01-04, License - CC BY-SA 4.0
(setq org-agenda-files (directory-files-recursively org-directory "\\.org$"))
(setq org-refile-targets '((org-agenda-files :maxlevel . 3)))
(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)
;; Enable Org mode
(require 'org)

(setq org-return-follows-link  t)
;; Make Org mode work with files ending in .org
;; (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
;; The above is the default in recent emacsen
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(evil helm)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
