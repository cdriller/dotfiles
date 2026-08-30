;;; init-files.el --- Shortcuts to frequently visited files -*- lexical-binding: t; -*-

;;; Commentary:
;; Quick-open commands for init.el and the PARA-style plan files,
;; plus a helper to link to an org heading.

;;; Code:

(defun my/edit-init-file ()
  "Open the Emacs init file."
  (interactive)
  (find-file user-init-file))

(global-set-key (kbd "C-c e") #'my/edit-init-file)

(defun my/edit-someday-file ()
  "Open someday file."
  (interactive)
  (find-file "~/plan/someday.org"))

(global-set-key (kbd "C-c f s") #'my/edit-someday-file)
(which-key-add-key-based-replacements
  "C-c f s" "someday")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GTD horizons of focus

(which-key-add-key-based-replacements
  "C-c h" "horizons")

(defvar prilepp/actions-directory "~/actions/"
  "Directory containing one org file per GTD context (horizon 0).")

(defun prilepp/actions--list-contexts ()
  "Return the context names (without .org) under `prilepp/actions-directory'."
  (let ((root (expand-file-name prilepp/actions-directory)))
    (when (file-directory-p root)
      (mapcar #'file-name-sans-extension
              (directory-files root nil "\\.org\\'")))))

(defun prilepp/actions-find ()
  "Select a context under `prilepp/actions-directory' and open it,
creating a new context file if it doesn't exist yet."
  (interactive)
  (let* ((dir (expand-file-name prilepp/actions-directory))
         (contexts (prilepp/actions--list-contexts))
         (choice (completing-read "Context: " contexts))
         (file (expand-file-name (concat choice ".org") dir)))
    (unless (file-exists-p file)
      (make-directory dir t)
      (with-temp-buffer (write-file file)))
    (find-file file)))

(global-set-key (kbd "C-c a") #'prilepp/actions-find)
(which-key-add-key-based-replacements
  "C-c a" "actions (h0)")

(defun my/edit-goals-file ()
  "Open goals file (horizon 3)."
  (interactive)
  (find-file "~/plan/goals.org"))

(global-set-key (kbd "C-c h g") #'my/edit-goals-file)
(which-key-add-key-based-replacements
  "C-c h g" "goals (h3)")

(defun my/edit-vision-file ()
  "Open vision file (horizon 4)."
  (interactive)
  (find-file "~/plan/vision.org"))

(global-set-key (kbd "C-c h v") #'my/edit-vision-file)
(which-key-add-key-based-replacements
  "C-c h v" "vision (h4)")

(defun my/edit-purpose-file ()
  "Open purpose & principles file (horizon 5)."
  (interactive)
  (find-file "~/plan/purpose.org"))

(global-set-key (kbd "C-c h u") #'my/edit-purpose-file)
(which-key-add-key-based-replacements
  "C-c h u" "purpose (h5)")

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

(provide 'init-files)
;;; init-files.el ends here
