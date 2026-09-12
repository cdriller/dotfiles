;;; init-org.el --- Org, org-roam, and citation setup -*- lexical-binding: t; -*-

;;; Commentary:
;; Org mode itself, org-roam (+ UI), and citar/org-cite for citations.

;;; Code:

(defun my/org-horizon-files ()
  "Return all .org files in the horizons directory."
  (directory-files-recursively "~/notes/horizons/" "\\.org\\'"))

(use-package org
  :ensure nil
  :init
  (setq org-id-link-to-org-use-id t)
  (setq org-refile-targets
      '((my/org-horizon-files :maxlevel . 3)))
  )

(use-package org-roam
  :demand t
  :custom
  (org-roam-directory (expand-file-name "notes/slipbox" (getenv "HOME")))
  :bind
  (("C-c v b" . org-roam-buffer-toggle))
  :init
  (which-key-add-key-based-replacements
    "C-c v b" "backlinks")
  :config
  (org-roam-db-autosync-mode))

(defun prilepp/org-note-complete (&optional _)
  "Select an existing note for `org-insert-link' (C-c C-l); returns an id: link."
  (concat "id:" (org-roam-node-id (org-roam-node-read))))

(with-eval-after-load 'org
  (org-link-set-parameters "note" :complete #'prilepp/org-note-complete))

(use-package org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(global-set-key (kbd "C-c v u") #'org-roam-ui-open)
(which-key-add-key-based-replacements
  "C-c v u" "roam-ui")

(use-package citar
  :custom
  (citar-bibliography '("~/.local/share/bib-exports/My Library.bib"))
  ;; Ordner, in dem du deine annotierten PDFs ablegst:
  (citar-library-paths '("~/media/books/"))
  ;; Notizen liegen im org-roam-Verzeichnis:
  (citar-notes-paths (list (expand-file-name "notes/slipbox" (getenv "HOME")))))

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

(defun prilepp/insert-link (&optional arg)
  "Insert a link or citation via one unified prompt.
Offers every registered `org-link-parameters' type plus \"citation\";
dispatches to `citar-insert-citation' for citations, otherwise reuses
`org-insert-link' (including its own :complete UI) for the chosen type.
With a `C-u' prefix (or `C-u C-u'), falls through to the standard
`org-insert-link' file-completion behavior."
  (interactive "P")
  (if (member arg '((4) (16)))
      (org-insert-link arg)
    (let* ((types (append (mapcar #'car org-link-parameters) '("citation")))
           (choice (completing-read "Link type: " types)))
      (if (equal choice "citation")
          (citar-insert-citation)
        (org-insert-link nil (org-link--try-special-completion choice))))))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-l") #'prilepp/insert-link))

(provide 'init-org)
;;; init-org.el ends here
