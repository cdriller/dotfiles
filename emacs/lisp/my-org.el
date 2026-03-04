;;; my-org.el --- My config for Org mode. -*- lexical-binding:t; -*-


;;; Commentary:


;;; Code:
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "M-h") #'windmove-left)
  (define-key org-mode-map (kbd "M-j") #'windmove-down)
  (define-key org-mode-map (kbd "M-k") #'windmove-up)
  (define-key org-mode-map (kbd "M-l") #'windmove-right)
  '(progn
     (define-key org-mode-map [remap org-cycle] #'ignore)
     (define-key org-mode-map [remap org-shifttab] #'ignore)))
; (global-set-key (kbd "M-a") 'org-agenda)
; (global-set-key (kbd "M-c") 'org-capture)
;
; ;;;; Helm configuration
; ;(unless (package-installed-p 'helm)
; ;  (package-install 'helm))
; ;(require 'helm)
; ;(helm-mode 1) ; facultative.
; ;(global-set-key (kbd "M-x") 'helm-M-x)
; ;(global-set-key (kbd "C-x C-f") 'helm-find-files)
;
;;;;Org mode configuration
(setq org-directory "~/org/")
(setq org-default-notes-file (concat org-directory "/inbox.org"))
(setq org-capture-templates
      '(("t" "Todo" entry (file org-default-notes-file)
         "* %?")))
; source - https://stackoverflow.com/a
; Posted by Mingwei Zhang, modified by community. See post 'Timeline' for change history
; Retrieved 2026-01-04, License - CC BY-SA 4.0
(setq org-agenda-files (directory-files-recursively org-directory "\\.org$"))
(setq org-refile-targets '((org-agenda-files :maxlevel . 3)))
(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)
(setq org-agenda-skip-deadline-prewarning-if-scheduled t)
(require 'org-habit)
(setq org-todo-keywords '((sequence "ACTION(a)" "PROJECT(p)" "|" "DONE(d)")))
;; Enable Org mode
(require 'org)
(setq org-return-follows-link  t)
(setq org-archive-location "archive.org::")

; Quelle: https://gist.github.com/n2o4/65062bf378a6d6f575f71498deb20c80
(eval-after-load 'org-agenda
 '(progn
    (evil-set-initial-state 'org-agenda-mode 'normal)
    (evil-define-key 'normal org-agenda-mode-map
      (kbd "<RET>") 'org-agenda-switch-to
      (kbd "\t") 'org-agenda-goto

      "q" 'org-agenda-quit
      "r" 'org-agenda-redo
      "S" 'org-save-all-org-buffers
      "gj" 'org-agenda-goto-date
      "gJ" 'org-agenda-clock-goto
      "gm" 'org-agenda-bulk-mark
      "go" 'org-agenda-open-link
      "s" 'org-agenda-schedule
      "+" 'org-agenda-priority-up
      "," 'org-agenda-priority
      "-" 'org-agenda-priority-down
      "y" 'org-agenda-todo-yesterday
      "n" 'org-agenda-add-note
      "t" 'org-agenda-todo
      ":" 'org-agenda-set-tags
      ";" 'org-timer-set-timer
      "I" 'helm-org-task-file-headings
      "i" 'org-agenda-clock-in-avy
      "O" 'org-agenda-clock-out-avy
      "u" 'org-agenda-bulk-unmark
      "x" 'org-agenda-exit
      "j"  'org-agenda-next-line
      "k"  'org-agenda-previous-line
      "vt" 'org-agenda-toggle-time-grid
      "va" 'org-agenda-archives-mode
      "vw" 'org-agenda-week-view
      "vl" 'org-agenda-log-mode
      "vd" 'org-agenda-day-view
      "vc" 'org-agenda-show-clocking-issues
      "g/" 'org-agenda-filter-by-tag
      "o" 'delete-other-windows
      "gh" 'org-agenda-holiday
      "gv" 'org-agenda-view-mode-dispatch
      "f" 'org-agenda-later
      "b" 'org-agenda-earlier
      "c" 'helm-org-capture-templates
      "e" 'org-agenda-set-effort
      "n" nil  ; evil-search-next
      "{" 'org-agenda-manipulate-query-add-re
      "}" 'org-agenda-manipulate-query-subtract-re
      "A" 'org-agenda-toggle-archive-tag
      "." 'org-agenda-goto-today
      "0" 'evil-digit-argument-or-evil-beginning-of-line
      "<" 'org-agenda-filter-by-category
      ">" 'org-agenda-date-prompt
      "F" 'org-agenda-follow-mode
      "D" 'org-agenda-deadline
      "H" 'org-agenda-holidays
      "J" 'org-agenda-next-date-line
      "K" 'org-agenda-previous-date-line
      "L" 'org-agenda-recenter
      "P" 'org-agenda-show-priority
      "R" 'org-agenda-clockreport-mode
      "Z" 'org-agenda-sunrise-sunset
      "T" 'org-agenda-show-tags
      "X" 'org-agenda-clock-cancel
      "[" 'org-agenda-manipulate-query-add
      "g\\" 'org-agenda-filter-by-tag-refine
      "]" 'org-agenda-manipulate-query-subtract)))

(provide 'my-org)
;;; my-org.el ends here
