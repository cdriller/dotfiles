;;; init-contacts.el --- vdirel contacts integration -*- lexical-binding: t; -*-

;;; Commentary:
;; Contact lookup via vdirel, an org "contact:" link type, and helpers
;; to link/create Person-Notes for a contact in `prilepp/persons-directory'
;; (~/persons/, independent of org-roam).

;;; Code:

(use-package vdirel
  :ensure t
  :custom
  (vdirel-repository "~/.local/share/vdirsyncer/contacts/contacts"))

(defvar prilepp/persons-directory "~/persons/"
  "Directory where person notes are stored")

(defun prilepp/slugify (title)
  "Return a filename-safe, lowercase, dash-separated slug for TITLE."
  (let* ((s (downcase title))
         (s (replace-regexp-in-string "[^[:alnum:]]+" "-" s))
         (s (replace-regexp-in-string "\\`-+\\|-+\\'" "" s)))
    s))

(defun prilepp/vcf-field (file field)
  "Return the value of FIELD (e.g. \"FN\", \"EMAIL\") from vcf FILE, or nil."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (when (re-search-forward (concat "^" field "[^:]*:\\(.*\\)$") nil t)
      (string-trim (match-string 1)))))

(defun prilepp/vcf-uid-file (uid)
  "Return the vcf file in `vdirel-repository' whose UID matches UID, or nil."
  (seq-find (lambda (f) (equal (prilepp/vcf-field f "UID") uid))
            (directory-files vdirel-repository t "\\.vcf\\'")))

(defun prilepp/vcf-candidates ()
  "Return an alist of (FULLNAME . FILE) for all contacts."
  (mapcar (lambda (f)
            (cons (or (prilepp/vcf-field f "FN") (file-name-base f)) f))
          (directory-files vdirel-repository t "\\.vcf\\'")))

(defun prilepp/org-contact-follow (uid &optional _)
  "Follow a contact: link by opening the vCard whose UID is UID."
  (let ((file (prilepp/vcf-uid-file uid)))
    (if file
        (find-file-read-only file)
      (user-error "Kein Kontakt mit UID %s gefunden" uid))))

(defun prilepp/org-contact-complete (&optional _)
  "Interactively select a contact for `org-insert-link' (C-c C-l)."
  (let* ((candidates (prilepp/vcf-candidates))
         (choice (completing-read "Contact: " candidates nil t))
         (uid (prilepp/vcf-field (cdr (assoc choice candidates)) "UID")))
    (concat "contact:" uid)))

(with-eval-after-load 'org
  (org-link-set-parameters "contact"
                            :follow #'prilepp/org-contact-follow
                            :complete #'prilepp/org-contact-complete))

(defun prilepp/org-insert-contact-link ()
  "Select a contact and insert `[[contact:UID][Name]]' at point."
  (interactive)
  (let* ((candidates (prilepp/vcf-candidates))
         (choice (completing-read "Contact: " candidates nil t))
         (uid (prilepp/vcf-field (cdr (assoc choice candidates)) "UID")))
    (unless uid
      (user-error "Kontakt %s hat kein UID-Feld" choice))
    (insert (format "[[contact:%s][%s]]" uid choice))))

(defun prilepp/org-roam-set-contact-uid ()
  "Select a contact and set CONTACT_UID on the current heading/node."
  (interactive)
  (let* ((candidates (prilepp/vcf-candidates))
         (choice (completing-read "Contact: " candidates nil t))
         (uid (prilepp/vcf-field (cdr (assoc choice candidates)) "UID")))
    (unless uid
      (user-error "Kontakt %s hat kein UID-Feld" choice))
    (org-set-property "CONTACT_UID" uid)))

(defun prilepp/contact-uid-has-note (uid)
  "Return the file(s) containing CONTACT_UID: UID as a Person-Note, or nil."
  (let ((dir (expand-file-name prilepp/persons-directory)))
    (when (file-directory-p dir)
      (with-temp-buffer
        (when (zerop (call-process "rg" nil t nil "-l" "-F"
                                    (concat ":CONTACT_UID: " uid)
                                    dir))
          (split-string (string-trim (buffer-string)) "\n"))))))

(defun prilepp/vcf-create (name)
  "Create a minimal vCard for NAME in `vdirel-repository'; return its UID."
  (let* ((uid (org-id-uuid))
         (file (expand-file-name (format "%s.vcf" uid) vdirel-repository)))
    (with-temp-buffer
      (insert (format "BEGIN:VCARD\nVERSION:3.0\nFN:%s\nUID:%s\nEND:VCARD\n" name uid))
      (write-file file))
    uid))

(defun prilepp/person-ensure-file (name)
  "Ensure a Person-Note for the contact NAME exists in `prilepp/persons-directory';
return its path. If no matching contact exists yet in `vdirel-repository',
create one first."
  (let* ((candidates (prilepp/vcf-candidates))
         (existing-file (cdr (assoc name candidates)))
         (uid (cond
               ((null existing-file) (prilepp/vcf-create name))
               ((prilepp/vcf-field existing-file "UID"))
               (t (user-error "Kontakt %s hat kein UID-Feld" name)))))
    (or (car (prilepp/contact-uid-has-note uid))
        (let* ((dir (expand-file-name prilepp/persons-directory))
               (file (expand-file-name
                      (format "%s.org" (prilepp/slugify name))
                      dir)))
          (make-directory dir t)
          (with-temp-buffer
            (insert (format ":PROPERTIES:\n:CONTACT_UID: %s\n:END:\n#+title: %s\n#+filetags: :person:\n"
                            uid name))
            (write-file file))
          file))))

(defun prilepp/new-person-note-for (name)
  "Create or open a Person-Note for the contact NAME."
  (find-file (prilepp/person-ensure-file name)))

(defun prilepp/new-person-note ()
  "Create or open a Person-Note for a contact, prompting for the name."
  (interactive)
  (prilepp/new-person-note-for (completing-read "Contact: " (prilepp/vcf-candidates))))

(provide 'init-contacts)
;;; init-contacts.el ends here
