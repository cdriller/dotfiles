;;; init-basics.el --- Basic UI and editing settings -*- lexical-binding: t; -*-

;;; Commentary:
;; Misc top-level settings that don't warrant their own module.

;;; Code:

(load-theme 'modus-vivendi t)
(tool-bar-mode -1)
(setq create-lockfiles nil)

(setq mac-option-modifier 'meta
      mac-right-option-modifier 'none)

(setq vc-follow-symlinks t)

;; do not truncate lines
(global-visual-line-mode 1)

;; Auto-save the actual file (not just a #backup#) for anything under ~/notes
(setq auto-save-visited-predicate
      (lambda ()
        (and buffer-file-name
             (file-in-directory-p buffer-file-name (expand-file-name "~/notes/")))))
(auto-save-visited-mode 1)

(use-package emacs
  :ensure nil
  :bind (("M-h" . windmove-left)
         ("M-j" . windmove-down)
         ("M-k" . windmove-up)
         ("M-l" . windmove-right)))

(provide 'init-basics)
;;; init-basics.el ends here
