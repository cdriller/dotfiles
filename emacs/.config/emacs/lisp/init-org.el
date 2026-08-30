;;; init-org.el --- Org, org-roam, and citation setup -*- lexical-binding: t; -*-

;;; Commentary:
;; Org mode itself, org-roam (+ UI), and citar/org-cite for citations.

;;; Code:

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
  (("C-c f n" . org-roam-node-find)
   ("C-c l n" . org-roam-node-insert)
   ("C-c v b" . org-roam-buffer-toggle))
  :init
  (which-key-add-key-based-replacements
    "C-c f n" "note"
    "C-c l n" "note"
    "C-c v b" "backlinks")
  :config
  (org-roam-db-autosync-mode))

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
  (citar-notes-paths (list (expand-file-name "notes" (getenv "HOME"))))
  :bind
  (("C-c f l" . citar-open-notes)
   ("C-c l l" . citar-insert-citation))
   :init
   (which-key-add-key-based-replacements
     "C-c f l" "literature"
     "C-c l l" "literature"))

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

(provide 'init-org)
;;; init-org.el ends here
