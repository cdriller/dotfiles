;;; init-completion.el --- Completion framework -*- lexical-binding: t; -*-

;;; Commentary:
;; Vertico/orderless/consult minibuffer completion, plus which-key.

;;; Code:

(use-package vertico
  :config
  (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :ensure t
  :demand t
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)))

(defun prilepp/notes-grep ()
  "Grep across all notes under ~/notes."
  (interactive)
  (consult-ripgrep "~/notes"))

(global-set-key (kbd "C-c g") #'prilepp/notes-grep)
(which-key-add-key-based-replacements
  "C-c g" "grep")

(use-package which-key
  :ensure nil
  :config
  (which-key-mode)
  (which-key-add-key-based-replacements
    "C-c i" "insert"
    "C-c v" "view"))

(provide 'init-completion)
;;; init-completion.el ends here
