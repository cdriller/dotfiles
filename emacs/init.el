;;; my-config -- My personal Emacs configuration -*- lexical-binding:t; -*-
;;; Commentary:
;; This file is my personal Emacs configuration.

;;; Code:
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'package)
(require 'use-package)

(global-set-key (kbd "TAB") 'self-insert-command)

;; Ensure use-package is present. From here on out, all packages are loaded
;; with use-package, a macro for importing and installing packages. Also, refresh the package archive on load so we can pull the latest packages.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq
 use-package-always-ensure t ;; Makes sure to download new packages if they aren't already downloaded
 use-package-verbose t) ;; Package install logging. Packages break, it's nice to know why.

;; Nice macro for updating lists in place.
(defmacro append-to-list (target suffix)
  "Append SUFFIX to TARGET in place."
  `(setq ,target (append ,target ,suffix)))

;; Set up emacs package archives with 'package
(append-to-list package-archives
                '(("melpa" . "http://melpa.org/packages/") ;; Main package archive
                  ("melpa-stable" . "http://stable.melpa.org/packages/") ;; Some packages might only do stable releases?
                  ("org-elpa" . "https://orgmode.org/elpa/"))) ;; Org packages, I don't use org but seems like a harmless default

(package-initialize)

;; Slurp environment variables from the shell.
;; a.k.a. The Most Asked Question On r/emacs
(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

(use-package doom-themes
  :init
  (load-theme 'doom-one t))

(make-directory "/home/thorn/.config/emacs/auto-saves/" t)
(setq auto-save-file-name-transforms
      `((".*" "/home/thorn/.config/emacs/auto-saves/" t)))
(setq backup-directory-alist
      `(("." . "/home/thorn/.config/emacs/backups/")))
(make-directory "/home/thorn/.config/emacs/backups/" t)

;; Any Customize-based settings should live in custom.el, not here.
(setq custom-file "/home/thorn.config/emacs/custom.el") ;; Without this emacs will dump generated custom settings in this file. No bueno.
(load custom-file 'noerror)

(setq-default truncate-lines nil)

;;; OS specific config
(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-a-linux* (eq system-type 'gnu/linux))

;; Emacs feels like it's developed with linux in mind, here are some mac UX improvments
(when *is-a-mac*
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none)
  (setq default-input-method "MacOSX"))

;; Some linux love, too
(when *is-a-linux*
  (setq x-super-keysym 'meta))

;; Fullscreen by default, as early as possible. This tiny window is not enough
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Make M-x and other mini-buffers sortable, filterable
(use-package ivy
  :init
  (ivy-mode 1)
  (setq ivy-height 15
        ivy-use-virtual-buffers t
        ivy-use-selectable-prompt t))

(use-package counsel
  :after ivy
  :init
  (counsel-mode 1)
  :bind (:map ivy-minibuffer-map))

; We need something to manage the various projects we work on
; and for common functionality like project-wide searching, fuzzy file finding etc.
(use-package projectile
  :ensure t
  :pin melpa-stable
  :init


  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))

; Counsel and projectile should work together.
(use-package counsel-projectile
  :ensure t
  :pin melpa-stable)

;; Company is the best Emacs completion system.
(use-package company
  :bind (("C-SPC" . company-complete))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0) ;; I always want completion, give it to me asap
  (company-dabbrev-downcase nil "Don't downcase returned candidates.")
  (company-show-numbers t "Numbers are helpful.")
  (company-tooltip-limit 10 "The more the merrier.")
  :config
  (global-company-mode) ;; We want completion everywhere

  ;; use numbers 0-9 to select company completion candidates
  (let ((map company-active-map))
    (mapc (lambda (x) (define-key map (format "%d" x)
                        `(lambda () (interactive) (company-complete-number ,x))))
          (number-sequence 0 9))))

;; Flycheck is the newer version of flymake and is needed to make lsp-mode not freak out.
(use-package flycheck
  :config
  (add-hook 'prog-mode-hook 'flycheck-mode) ;; always lint my code
  (add-hook 'after-init-hook #'global-flycheck-mode))

;; Package for interacting with language servers
(use-package lsp-mode
  :commands lsp
  :config
  (setq lsp-prefer-flymake nil ;; Flymake is outdated
 ;;       lsp-headerline-breadcrumb-mode nil)
  )) ;; I don't like the symbols on the header a-la-vscode, remove this if you like them.

(use-package npm)

(use-package which-key
  :config (which-key-mode t))

(use-package magit)
(use-package diff-hl)
(global-diff-hl-mode)

(use-package smartparens
  :ensure smartparens  ;; install the package
  :hook (prog-mode text-mode markdown-mode) ;; add `smartparens-mode` to these hooks
  :config
  ;; load default config
  (require 'smartparens-config))

;;;; UI
(tool-bar-mode -1)
(menu-bar-mode -1)

;;;; keybindings
(global-set-key (kbd "M-l") 'windmove-right)
(global-set-key (kbd "M-h") 'windmove-left)
(global-set-key (kbd "M-k") 'windmove-up)
(global-set-key (kbd "M-j") 'windmove-down)

(require 'my-evil)
(require 'my-org)
;;; init.el ends here
