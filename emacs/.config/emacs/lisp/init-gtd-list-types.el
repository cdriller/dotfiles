;;; init-gtd-list-types.el --- Shared macro for GTD list-type boilerplate -*- lexical-binding: t; -*-

;;; Commentary:
;; `prilepp/define-gtd-list-type' generates, from a compact per-type
;; declaration, the boilerplate that used to be hand-written once per
;; GTD list type (Project, Area, Life, Goal, Vision in
;; init-projects.el; Actions in init-files.el): a `*-directory' defvar,
;; a `*--list-*' completion helper, a `*-ensure-file' find-or-create
;; function, and a `*-find' command -- plus, when a link word is
;; supplied, an `org-link-set-parameters' registration, `*-follow'/
;; `*-complete' link handlers, and an `*-insert-*-link' command.
;;
;; Every one of the six existing types implemented this same shape by
;; hand (~230 duplicated lines total). A planned follow-up change adds
;; archive support to every GTD list type, which needs the same fix
;; applied six times; expressing all six through one macro means that
;; fix (and any future one) is written once instead of six times. See
;; design.md in the "emacs-refactor-horizon-setup" change for the full
;; rationale and the decisions behind this shape (slug vs. link-word,
;; optional link word, default-content forms).
;;
;; The macro expands to ordinary named `defvar'/`defun' forms (not
;; runtime-dispatched closures), so every name it generates is a real,
;; interned symbol that other files can keep referring to by name
;; exactly as before.
;;
;; Each expansion also upserts an entry into `prilepp/gtd-list-types',
;; an alist of slug -> metadata plist (`:slug', `:directory-var',
;; `:list-fn', `:ensure-fn', `:find-fn', `:link-word'). This lets
;; generic code (e.g. archive/restore support) iterate "every GTD list
;; type" without hardcoding one case per type. The upsert is done via
;; `setf'/`alist-get' rather than `push', so re-evaluating a
;; `prilepp/define-gtd-list-type' call (e.g. with `C-M-x' during
;; development) replaces its entry instead of duplicating it.

;;; Code:

(require 'cl-lib)

(defvar prilepp/gtd-list-types nil
  "Alist of GTD-list-type metadata plists, keyed by slug, registered by
`prilepp/define-gtd-list-type'.")

(defun prilepp/gtd-list-type--register (slug plist)
  "Upsert PLIST as the registered metadata for GTD-list-type SLUG."
  (setf (alist-get slug prilepp/gtd-list-types) plist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Entry titles: pickers show a file's `#+title:' instead of its filename

(defvar prilepp/gtd-list--title-cache (make-hash-table :test #'equal)
  "Map from absolute file name to (MTIME . TITLE) for `prilepp/gtd-list-file-title'.")

(defun prilepp/gtd-list--read-title (file)
  "Return the `#+title:' value in the head of FILE, or nil.
Only the first 4 KiB before the first org heading are considered."
  (with-temp-buffer
    (insert-file-contents file nil 0 4096)
    (goto-char (point-min))
    (let ((case-fold-search t)
          (limit (save-excursion
                   (if (re-search-forward "^\\*+[ \t]" nil t)
                       (match-beginning 0)
                     (point-max)))))
      (when (re-search-forward "^#\\+title:[ \t]*\\(.+\\)$" limit t)
        (let ((title (string-trim (match-string 1))))
          (unless (string-empty-p title) title))))))

(defun prilepp/gtd-list-file-title (file)
  "Return the `#+title:' of FILE, or nil if it has none.
Results are cached per file and revalidated against its modification time."
  (let* ((path (expand-file-name file))
         (mtime (file-attribute-modification-time (file-attributes path)))
         (cached (gethash path prilepp/gtd-list--title-cache)))
    (when mtime
      (if (and cached (time-equal-p (car cached) mtime))
          (cdr cached)
        (let ((title (prilepp/gtd-list--read-title path)))
          (puthash path (cons mtime title) prilepp/gtd-list--title-cache)
          title)))))

(defun prilepp/gtd-list--label-entries (pairs)
  "Turn PAIRS, a list of (NAME . TITLE-OR-NIL), into (LABEL NAME TITLE) entries.
TITLE falls back to NAME. LABEL is TITLE, with \" (NAME)\" appended when
another entry would show the same label."
  (let* ((entries (mapcar (lambda (pair)
                            (let ((title (or (cdr pair) (car pair))))
                              (list title (car pair) title)))
                          pairs))
         (counts (make-hash-table :test #'equal)))
    (dolist (entry entries)
      (cl-incf (gethash (car entry) counts 0)))
    (mapcar (lambda (entry)
              (if (> (gethash (car entry) counts) 1)
                  (list (format "%s (%s)" (nth 2 entry) (nth 1 entry))
                        (nth 1 entry) (nth 2 entry))
                entry))
            entries)))

(declare-function prilepp/gtd-list-archived-entries "init-gtd-list-archive" (slug))

(defun prilepp/gtd-list-entries (slug &optional include-archived)
  "Return (LABEL NAME TITLE) entries for the GTD list type SLUG.
NAME is the filename without .org, TITLE the file's `#+title:' (or NAME),
and LABEL the unique string pickers show. Active entries come first;
with INCLUDE-ARCHIVED the archived ones follow."
  (let* ((plist (alist-get slug prilepp/gtd-list-types))
         (root (expand-file-name (symbol-value (plist-get plist :directory-var)))))
    (prilepp/gtd-list--label-entries
     (append
      (mapcar (lambda (name)
                (cons name (prilepp/gtd-list-file-title
                            (expand-file-name (concat name ".org") root))))
              (funcall (plist-get plist :list-fn)))
      (when include-archived
        (prilepp/gtd-list-archived-entries slug))))))

(defun prilepp/gtd-list-entry-name (label entries)
  "Return the NAME of the entry in ENTRIES labelled LABEL.
A LABEL that matches no entry is a name the user typed, and is its own NAME."
  (or (nth 1 (assoc label entries)) label))

(cl-defmacro prilepp/define-gtd-list-type
    (slug &key directory list-fn find-fn find-prompt ensure-fn
          default-content link-word link-follow-fn link-complete-fn
          insert-fn insert-prompt)
  "Define the standard GTD-list-type boilerplate for SLUG.

DIRECTORY is the directory (a string) holding one org file per entry;
it becomes the value of a generated `prilepp/SLUG-directory' defvar.
LIST-FN, FIND-FN, and ENSURE-FN are the symbols to define as the
listing, find, and ensure-file functions respectively. FIND-PROMPT is
the `completing-read' prompt string used by FIND-FN.

DEFAULT-CONTENT controls what a newly-created entry file is seeded
with: nil for an empty file, a literal string for static content, or
a string containing \"%s\" to have the entry name interpolated via
`format'.

When LINK-WORD (a string) is non-nil, this additionally registers an
org link type named LINK-WORD via `org-link-set-parameters', defines
LINK-FOLLOW-FN and LINK-COMPLETE-FN as its :follow/:complete handlers,
and defines INSERT-FN as an interactive command that inserts a
\"[[LINK-WORD:NAME][NAME]]\" link at point, prompting with
INSERT-PROMPT. Entries are offered by their file's `#+title:' (see
`prilepp/gtd-list-entries'); the link target stays the filename and the
description is the title. When LINK-WORD is nil, none of link-related
forms are generated.

A new entry file always starts with \"#+title: NAME\", followed by
DEFAULT-CONTENT."
  (let ((directory-var (intern (format "prilepp/%s-directory" slug))))
    `(progn
       (defvar ,directory-var ,directory
         ,(format "Directory containing one org file per %s entry." slug))

       (prilepp/gtd-list-type--register
        ',slug
        (list :slug ',slug
              :directory-var ',directory-var
              :list-fn ',list-fn
              :ensure-fn ',ensure-fn
              :find-fn ',find-fn
              :link-word ,link-word))

       (defun ,list-fn ()
         ,(format "Return the entry names (without .org) under `%s'." directory-var)
         (let ((root (expand-file-name ,directory-var)))
           (when (file-directory-p root)
             (mapcar #'file-name-sans-extension
                     (directory-files root nil "\\.org\\'")))))

       (defun ,ensure-fn (name)
         ,(format "Ensure NAME's file exists under `%s'; return its path." directory-var)
         (let ((file (expand-file-name (concat name ".org") ,directory-var)))
           (unless (file-exists-p file)
             (make-directory ,directory-var t)
             (with-temp-buffer
               (insert (format "#+title: %s\n" name))
               ,(cond
                 ((null default-content) nil)
                 ((and (stringp default-content) (string-match-p "%s" default-content))
                  `(insert (format ,default-content name)))
                 (t `(insert ,default-content)))
               (write-file file)))
           file))

       (defun ,find-fn ()
         ,(format "Select an entry under `%s' and open it,
creating a new file if it doesn't exist yet." directory-var)
         (interactive)
         (let* ((entries (prilepp/gtd-list-entries ',slug))
                (label (completing-read ,find-prompt (mapcar #'car entries))))
           (find-file (,ensure-fn (prilepp/gtd-list-entry-name label entries)))))

       ,@(when link-word
           `((defun ,link-follow-fn (name &optional _)
               ,(format "Follow a %s link: open (or create) NAME's file." link-word)
               (find-file (,ensure-fn name)))

             (defun ,link-complete-fn (&optional _)
               ,(format "Interactively select an entry for `org-insert-link' (C-c C-l)." )
               (let* ((entries (prilepp/gtd-list-entries ',slug))
                      (label (completing-read ,insert-prompt (mapcar #'car entries))))
                 (concat ,(concat link-word ":") (prilepp/gtd-list-entry-name label entries))))

             (with-eval-after-load 'org
               (org-link-set-parameters ,link-word
                                         :follow #',link-follow-fn
                                         :complete #',link-complete-fn))

             (defun ,insert-fn ()
               ,(format "Select an entry and insert `[[%s:NAME][TITLE]]' at point,
creating the entry if it doesn't exist yet." link-word)
               (interactive)
               (let* ((entries (prilepp/gtd-list-entries ',slug))
                      (label (completing-read ,insert-prompt (mapcar #'car entries)))
                      (entry (assoc label entries))
                      (name (or (nth 1 entry) label))
                      (title (or (nth 2 entry) name)))
                 (,ensure-fn name)
                 (insert (format ,(concat "[[" link-word ":%s][%s]]") name title)))))))))

(provide 'init-gtd-list-types)
;;; init-gtd-list-types.el ends here
