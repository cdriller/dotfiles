;;; init-dashboard.el --- startup overview of notes -*- lexical-binding: t; -*-

;;; Commentary:
;; A small *dashboard* buffer shown on startup (via `initial-buffer-choice',
;; which Emacs only uses when no file was given on the command line):
;; open actions per context, today's calendar events, and active projects.
;; Context/project entries are buttons (RET opens them); everything reuses
;; existing helpers (`prilepp/actions-ensure-file', `prilepp/proj-ensure-file',
;; `prilepp/vdir-calendar-dirs'/`prilepp/vdir-build-ics' + calfw-ical's own
;; recurrence-aware `calfw-ical-to-calendar' for correctly expanded
;; recurring events).

;;; Code:

(defun prilepp/dashboard--open-count (file)
  "Return the number of TODO/WAITING headings in FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (count-matches "^\\*+ \\(TODO\\|WAITING\\)\\_>" (point-min) (point-max))))

(defun prilepp/dashboard--todays-events ()
  "Return a list of (CALENDAR-NAME . calfw-event) for today, across all
discovered vdirsyncer calendars, with recurrences correctly expanded."
  (let ((today (calendar-current-date))
        events)
    (dolist (pair (prilepp/vdir-calendar-dirs))
      (dolist (ev (calfw-ical-to-calendar (prilepp/vdir-build-ics (cdr pair)) today today))
        (unless (eq (car-safe ev) 'periods)
          (push (cons (car pair) ev) events))))
    (nreverse events)))

(defun prilepp/dashboard--insert-button (label file)
  "Insert a button labeled LABEL that opens FILE when pressed."
  (insert-text-button label
                       'action (lambda (_) (find-file file))
                       'follow-link t
                       'face 'link))

(defun prilepp/dashboard-buffer ()
  "Create and return the *dashboard* buffer."
  (with-current-buffer (get-buffer-create "*dashboard*")
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert (propertize "Dashboard" 'face '(:height 1.5 :weight bold)) "\n")
      (insert (format-time-string "%A, %d.%m.%Y") "\n\n")

      (insert (propertize "Offene Actions\n" 'face 'bold))
      (let ((any nil))
        (dolist (name (prilepp/actions--list-contexts))
          (let* ((file (prilepp/actions-ensure-file name))
                 (n (prilepp/dashboard--open-count file)))
            (when (> n 0)
              (setq any t)
              (insert "  ")
              (prilepp/dashboard--insert-button name file)
              (insert (format " — %d offen\n" n)))))
        (unless any (insert "  Keine offenen Actions\n")))
      (insert "\n")

      (insert (propertize "Heutige Termine\n" 'face 'bold))
      (let ((events (prilepp/dashboard--todays-events)))
        (if events
            (dolist (ev events)
              (let* ((cal (car ev))
                     (event (cdr ev))
                     (time (calfw-event-start-time event)))
                (insert (format "  %s%s (%s)\n"
                                (if time (concat time " ") "")
                                (calfw-event-title event)
                                cal))))
          (insert "  Keine Termine heute\n")))
      (insert "\n")

      (insert (propertize "Aktive Projekte\n" 'face 'bold))
      (let ((projects (prilepp/proj--list-projects)))
        (if projects
            (dolist (name projects)
              (insert "  ")
              (prilepp/dashboard--insert-button name (prilepp/proj-ensure-file name))
              (insert "\n"))
          (insert "  Keine Projekte\n")))

      (goto-char (point-min))
      (special-mode)
      (setq buffer-read-only t))
    (current-buffer)))

(unless noninteractive
  (setq initial-buffer-choice #'prilepp/dashboard-buffer))

(provide 'init-dashboard)
;;; init-dashboard.el ends here
