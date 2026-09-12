;;; init-calendar.el --- calfw calendar view over vdirsyncer calendars -*- lexical-binding: t; -*-

;;; Commentary:
;; vdirsyncer syncs calendars into one vdir-format folder per calendar
;; under `prilepp/vdir-calendars-directory' (one .ics file per event, like
;; vdirel's contact storage). calfw/calfw-ical expect a single combined
;; .ics per source, so `prilepp/vdir-build-ics' stitches the VEVENT (and a
;; VTIMEZONE) blocks from a calendar's individual files into one synthetic
;; .ics on demand.

;;; Code:

(use-package calfw :ensure t :demand t)
(use-package calfw-ical :ensure t :after calfw :demand t)

(defvar prilepp/vdir-calendars-directory "~/.local/share/vdirsyncer/calendars/"
  "Root directory containing one vdir-format calendar folder per calendar.")

(defvar prilepp/calfw-colors
  '("SkyBlue2" "OliveDrab1" "LightSalmon" "Plum2" "Khaki1" "LightSteelBlue1")
  "Colors cycled through for each discovered calendar.")

(defun prilepp/vdir-calendar-dirs ()
  "Return (NAME . PATH) for each non-empty, non-UUID-named calendar folder
under `prilepp/vdir-calendars-directory'."
  (let ((root (expand-file-name prilepp/vdir-calendars-directory)))
    (seq-filter
     (lambda (pair) (directory-files (cdr pair) nil "\\.ics\\'"))
     (mapcar (lambda (name) (cons name (expand-file-name name root)))
             (seq-remove
              (lambda (name) (string-match-p "\\`[0-9A-Fa-f-]\\{36\\}\\'" name))
              (seq-filter (lambda (name) (file-directory-p (expand-file-name name root)))
                          (directory-files root nil "^[^.]")))))))

(defun prilepp/vdir--extract-blocks (type)
  "Return all \"BEGIN:TYPE\"...\"END:TYPE\" blocks in the current buffer."
  (let (blocks)
    (goto-char (point-min))
    (while (re-search-forward (format "^BEGIN:%s$" type) nil t)
      (let ((start (line-beginning-position)))
        (when (re-search-forward (format "^END:%s$" type) nil t)
          (push (buffer-substring-no-properties start (line-end-position)) blocks))))
    (nreverse blocks)))

(defun prilepp/vdir-build-ics (dir)
  "Concatenate VEVENT/VTIMEZONE blocks from every .ics file in DIR
into one synthetic combined .ics temp file; return its path."
  (let ((out (make-temp-file "prilepp-cal-" nil ".ics"))
        (tz nil)
        (events nil))
    (dolist (f (directory-files dir t "\\.ics\\'"))
      (with-temp-buffer
        (insert-file-contents f)
        (unless tz
          (setq tz (car (prilepp/vdir--extract-blocks "VTIMEZONE"))))
        (setq events (append events (prilepp/vdir--extract-blocks "VEVENT")))))
    (with-temp-file out
      (insert "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//prilepp//emacs-calfw//EN\n")
      (when tz (insert tz "\n"))
      (dolist (ev events) (insert ev "\n"))
      (insert "END:VCALENDAR\n"))
    out))

(defun prilepp/calfw-open ()
  "Open a calfw calendar view fed from the vdirsyncer calendar folders."
  (interactive)
  (let ((sources
         (cl-loop for (name . dir) in (prilepp/vdir-calendar-dirs)
                  for color in (or prilepp/calfw-colors '("SkyBlue2"))
                  collect (calfw-ical-create-source (prilepp/vdir-build-ics dir) name color))))
    (calfw-open-calendar-buffer :contents-sources sources)))

(global-set-key (kbd "C-c v c") #'prilepp/calfw-open)
(which-key-add-key-based-replacements
  "C-c v c" "calendar")

(defun prilepp/calendar-grep ()
  "Grep across all calendar events under `prilepp/vdir-calendars-directory'."
  (interactive)
  (consult-ripgrep prilepp/vdir-calendars-directory))

(global-set-key (kbd "C-c c") #'prilepp/calendar-grep)
(which-key-add-key-based-replacements
  "C-c c" "search calendar")

(defun prilepp/vdir-event-candidates ()
  "Return an alist of (SUMMARY . FILE) for every event under the
discovered vdirsyncer calendar folders."
  (let (candidates)
    (dolist (pair (prilepp/vdir-calendar-dirs))
      (dolist (file (directory-files (cdr pair) t "\\.ics\\'"))
        (with-temp-buffer
          (insert-file-contents file)
          (goto-char (point-min))
          (push (cons (if (re-search-forward "^SUMMARY:\\(.*\\)$" nil t)
                          (match-string 1)
                        (file-name-base file))
                      file)
                candidates))))
    (nreverse candidates)))

(defun prilepp/org-event-complete (&optional _)
  "Select a calendar event for `org-insert-link' (C-c C-l); returns a file: link."
  (let ((candidates (prilepp/vdir-event-candidates)))
    (concat "file:" (cdr (assoc (completing-read "Event: " candidates) candidates)))))

(with-eval-after-load 'org
  (org-link-set-parameters "event" :complete #'prilepp/org-event-complete))

(defun prilepp/org-insert-event-link ()
  "Select a calendar event and insert `[[file:PATH][SUMMARY]]' at point."
  (interactive)
  (let* ((candidates (prilepp/vdir-event-candidates))
         (choice (completing-read "Event: " candidates))
         (file (cdr (assoc choice candidates))))
    (insert (format "[[file:%s][%s]]" file choice))))

(provide 'init-calendar)
;;; init-calendar.el ends here
