;;; my-evil.el --- My config for evil mode. -*- lexical-binding:t; -*-


;;; Commentary:

;;; Code:
(unless (package-installed-p 'evil)
  (package-install 'evil))
(require 'evil)
(evil-mode 1)

; evil spc, ret and tab do not any usefull that's why disable it so less important
; keybindings fire
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil)
  (define-key evil-insert-state-map (kbd "TAB") 'self-insert-command)
  (define-key evil-normal-state-map (kbd"TAB") 'evil-jump-forward))

(evil-set-undo-system 'undo-redo)
(provide 'my-evil)
;;; my-evil.el ends here
