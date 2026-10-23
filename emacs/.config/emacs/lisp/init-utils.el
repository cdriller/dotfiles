;;; init-utils.el --- Generic, cross-module utility functions -*- lexical-binding: t; -*-

;;; Commentary:
;; Small helpers with no domain of their own, used from more than one
;; other module. Modules that call into this file `require' it
;; explicitly instead of relying on load order.

;;; Code:

(defun prilepp/slugify (title)
  "Return a filename-safe, lowercase, dash-separated slug for TITLE."
  (let* ((s (downcase title))
         (s (replace-regexp-in-string "[^[:alnum:]]+" "-" s))
         (s (replace-regexp-in-string "\\`-+\\|-+\\'" "" s)))
    s))

(provide 'init-utils)
;;; init-utils.el ends here
