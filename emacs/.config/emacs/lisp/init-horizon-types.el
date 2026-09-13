;;; init-horizon-types.el --- Shared macro for GTD horizon-type boilerplate -*- lexical-binding: t; -*-

;;; Commentary:
;; `prilepp/define-horizon-type' generates, from a compact per-type
;; declaration, the boilerplate that used to be hand-written once per
;; GTD "horizon type" (Project, Area, Life, Goal, Vision in
;; init-projects.el; Actions in init-files.el): a `*-directory' defvar,
;; a `*--list-*' completion helper, a `*-ensure-file' find-or-create
;; function, and a `*-find' command -- plus, when a link word is
;; supplied, an `org-link-set-parameters' registration, `*-follow'/
;; `*-complete' link handlers, and an `*-insert-*-link' command.
;;
;; Every one of the six existing types implemented this same shape by
;; hand (~230 duplicated lines total). A planned follow-up change adds
;; archive support to every horizon type, which needs the same fix
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
;; Each expansion also upserts an entry into `prilepp/horizon-types',
;; an alist of slug -> metadata plist (`:slug', `:directory-var',
;; `:list-fn', `:ensure-fn', `:find-fn', `:link-word'). This lets
;; generic code (e.g. archive/restore support) iterate "every horizon
;; type" without hardcoding one case per type. The upsert is done via
;; `setf'/`alist-get' rather than `push', so re-evaluating a
;; `prilepp/define-horizon-type' call (e.g. with `C-M-x' during
;; development) replaces its entry instead of duplicating it.

;;; Code:

(require 'cl-lib)

(defvar prilepp/horizon-types nil
  "Alist of horizon-type metadata plists, keyed by slug, registered by
`prilepp/define-horizon-type'.")

(defun prilepp/horizon-type--register (slug plist)
  "Upsert PLIST as the registered metadata for horizon-type SLUG."
  (setf (alist-get slug prilepp/horizon-types) plist))

(cl-defmacro prilepp/define-horizon-type
    (slug &key directory list-fn find-fn find-prompt ensure-fn
          default-content link-word link-follow-fn link-complete-fn
          insert-fn insert-prompt)
  "Define the standard horizon-type boilerplate for SLUG.

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
INSERT-PROMPT. When LINK-WORD is nil, none of link-related forms are
generated."
  (let ((directory-var (intern (format "prilepp/%s-directory" slug))))
    `(progn
       (defvar ,directory-var ,directory
         ,(format "Directory containing one org file per %s entry." slug))

       (prilepp/horizon-type--register
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
         (let ((name (completing-read ,find-prompt (,list-fn))))
           (find-file (,ensure-fn name))))

       ,@(when link-word
           `((defun ,link-follow-fn (name &optional _)
               ,(format "Follow a %s link: open (or create) NAME's file." link-word)
               (find-file (,ensure-fn name)))

             (defun ,link-complete-fn (&optional _)
               ,(format "Interactively select an entry for `org-insert-link' (C-c C-l)." )
               (concat ,(concat link-word ":") (completing-read ,insert-prompt (,list-fn))))

             (with-eval-after-load 'org
               (org-link-set-parameters ,link-word
                                         :follow #',link-follow-fn
                                         :complete #',link-complete-fn))

             (defun ,insert-fn ()
               ,(format "Select an entry and insert `[[%s:NAME][NAME]]' at point,
creating the entry if it doesn't exist yet." link-word)
               (interactive)
               (let ((name (completing-read ,insert-prompt (,list-fn))))
                 (,ensure-fn name)
                 (insert (format ,(concat "[[" link-word ":%s][%s]]") name name)))))))))

(provide 'init-horizon-types)
;;; init-horizon-types.el ends here
