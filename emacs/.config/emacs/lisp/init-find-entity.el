;;; init-find-entity.el --- unified search/create across all entities -*- lexical-binding: t; -*-

;;; Commentary:
;; `prilepp/find-entity' (C-c o) replaces the old collection of per-entity
;; top-level shortcuts (actions/projects/areas/goals/vision/life/zettel/
;; literature/person/agenda/routine) with one `consult--multi'
;; prompt: each entity type is its own source with a group heading (shown
;; in the completion list) and a narrow key. Selecting an existing name
;; opens/jumps to it; typing a name that doesn't exist yet creates it —
;; narrow to a specific type first (its key + space) to control which type
;; a brand-new name becomes, exactly like `consult-buffer' (`b SPC name').
;; Without narrowing, a new name defaults to a Zettel in the slipbox
;; (Zettel is the `:default' source).
;; Journal (`C-c j') and someday (`C-c s') stay separate: neither is a
;; named collection, so they don't fit this find-or-create-by-name model.
;;
;; While in the C-c o minibuffer, RET runs the source's normal :action.
;; Alternatively: `C-i' inserts an org link to the highlighted candidate at
;; point (wherever C-c o was invoked from) instead of opening it; `C-c'
;; copies that same link to the kill ring. Both read the candidate via
;; `vertico--candidate' and decode which source it belongs to via
;; Consult's own `consult--multi-source'/`consult--tofu-strip' (the same
;; helpers `consult--multi' itself uses), then `throw' out of the
;; `consult--multi' call before its normal :action/:new post-processing
;; runs, so only the insert/copy happens — never also an open.

;;; Code:

(defun prilepp/org-roam-node-by-title (title)
  "Return the org-roam node with TITLE, or nil."
  (seq-find (lambda (nd) (equal (org-roam-node-title nd) title))
            (org-roam-node-list)))

(defvar prilepp/find-entity--sources nil
  "Vector of the sources used by the in-progress `prilepp/find-entity' call.")

(defun prilepp/find-entity--act (kind)
  "Throw the highlighted candidate plus KIND (`insert' or `copy') out of
the enclosing `prilepp/find-entity' call."
  (let ((cand (vertico--candidate)))
    (if (and cand (not (string-blank-p cand))
             (consult--tofu-p (aref cand (1- (length cand)))))
        (throw 'prilepp-find-entity
               (list kind (consult--tofu-strip cand)
                     (consult--multi-source prilepp/find-entity--sources cand)))
      (user-error "Erst mit RET anlegen, dann C-c o erneut für den Link"))))

(defun prilepp/find-entity-insert ()
  "Insert a link to the highlighted `prilepp/find-entity' candidate at point."
  (interactive)
  (prilepp/find-entity--act 'insert))

(defun prilepp/find-entity-copy ()
  "Copy a link to the highlighted `prilepp/find-entity' candidate."
  (interactive)
  (prilepp/find-entity--act 'copy))

(defun prilepp/entity-sources ()
  "Return the list of `consult--multi' sources used by `prilepp/find-entity'
and `prilepp/read-entity-link'."
  (list
           `(:name "Action" :narrow ?0
             :items ,#'prilepp/actions--list-contexts
             :action ,(lambda (n) (find-file (prilepp/actions-ensure-file n)))
             :new ,(lambda (n) (find-file (prilepp/actions-ensure-file n)))
             :link ,(lambda (n) (format "[[file:%s][%s]]" (prilepp/actions-ensure-file n) n)))
           `(:name "Project" :narrow ?1
             :items ,#'prilepp/proj--list-projects
             :action ,(lambda (n) (find-file (prilepp/proj-ensure-file n)))
             :new ,(lambda (n) (find-file (prilepp/proj-ensure-file n)))
             :link ,(lambda (n) (format "[[file:%s][%s]]" (prilepp/proj-ensure-file n) n)))
           `(:name "Area" :narrow ?2
             :items ,#'prilepp/aor--list-aors
             :action ,(lambda (n) (find-file (prilepp/aor-ensure-file n)))
             :new ,(lambda (n) (find-file (prilepp/aor-ensure-file n)))
             :link ,(lambda (n) (format "[[file:%s][%s]]" (prilepp/aor-ensure-file n) n)))
           `(:name "Goal" :narrow ?3
             :items ,#'prilepp/goals--list-entries
             :action ,(lambda (n) (find-file (prilepp/goals-ensure-file n)))
             :new ,(lambda (n) (find-file (prilepp/goals-ensure-file n)))
             :link ,(lambda (n) (format "[[file:%s][%s]]" (prilepp/goals-ensure-file n) n)))
           `(:name "Vision" :narrow ?4
             :items ,#'prilepp/vision--list-entries
             :action ,(lambda (n) (find-file (prilepp/vision-ensure-file n)))
             :new ,(lambda (n) (find-file (prilepp/vision-ensure-file n)))
             :link ,(lambda (n) (format "[[file:%s][%s]]" (prilepp/vision-ensure-file n) n)))
           `(:name "Life" :narrow ?5
             :items ,#'prilepp/life--list-entries
             :action ,(lambda (n) (find-file (prilepp/life-ensure-file n)))
             :new ,(lambda (n) (find-file (prilepp/life-ensure-file n)))
             :link ,(lambda (n) (format "[[file:%s][%s]]" (prilepp/life-ensure-file n) n)))
           `(:name "Agenda" :narrow ?a
             :items ,#'prilepp/agendas--list-entries
             :action ,(lambda (n) (find-file (prilepp/agendas-ensure-file n)))
             :new ,(lambda (n) (find-file (prilepp/agendas-ensure-file n)))
             :link ,(lambda (n) (format "[[file:%s][%s]]" (prilepp/agendas-ensure-file n) n)))
           `(:name "Zettel" :narrow ?z :default t
             :items ,(lambda ()
                       (mapcar #'org-roam-node-title
                               (seq-remove #'org-roam-node-refs (org-roam-node-list))))
             :action ,(lambda (n) (org-roam-node-visit (prilepp/org-roam-node-by-title n)))
             :new ,(lambda (n) (org-roam-capture- :node (org-roam-node-create :title n)))
             :link ,(lambda (n) (format "[[id:%s][%s]]"
                                        (org-roam-node-id (prilepp/org-roam-node-by-title n)) n)))
           `(:name "Literature" :narrow ?l
             :items ,(lambda ()
                       (mapcar #'org-roam-node-title
                               (seq-filter #'org-roam-node-refs (org-roam-node-list))))
             :action ,(lambda (n) (org-roam-node-visit (prilepp/org-roam-node-by-title n)))
             :link ,(lambda (n) (format "[[id:%s][%s]]"
                                        (org-roam-node-id (prilepp/org-roam-node-by-title n)) n)))
           `(:name "Person" :narrow ?p
             :items ,(lambda () (mapcar #'car (prilepp/vcf-candidates)))
             :action ,#'prilepp/new-person-note-for
             :new ,#'prilepp/new-person-note-for
             :link ,(lambda (n) (format "[[file:%s][%s]]" (prilepp/person-ensure-file n) n)))
           `(:name "Routine" :narrow ?r
             :items ,(lambda () (mapcar #'car (prilepp/routine--candidates)))
             :action ,(lambda (n) (prilepp/routine-jump (cdr (assoc n (prilepp/routine--candidates)))))
             :new ,#'prilepp/routine-insert-new
             :link ,(lambda (n)
                      (let* ((marker (cdr (assoc n (prilepp/routine--candidates))))
                             (id (with-current-buffer (marker-buffer marker)
                                   (save-excursion (goto-char marker) (org-id-get-create)))))
                        (format "[[id:%s][%s]]" id n))))))

(defun prilepp/find-entity ()
  "Search or create across all named entities.
RET opens/jumps to the selection. `C-i' inserts a link to it at point
instead; `C-c' copies that link. See the Commentary above for details."
  (interactive)
  (let* ((sources (prilepp/entity-sources))
         (prilepp/find-entity--sources (vconcat sources))
         (keymap (let ((m (make-sparse-keymap)))
                   (define-key m (kbd "C-i") #'prilepp/find-entity-insert)
                   (define-key m (kbd "C-c") #'prilepp/find-entity-copy)
                   m))
         (result (catch 'prilepp-find-entity
                   (list 'normal (consult--multi sources :keymap keymap)))))
    (pcase result
      (`(insert ,name ,src) (insert (funcall (plist-get src :link) name)))
      (`(copy ,name ,src)
       (let ((link (funcall (plist-get src :link) name)))
         (kill-new link)
         (message "Kopiert: %s" link))))))

(global-set-key (kbd "C-c o") #'prilepp/find-entity)
(which-key-add-key-based-replacements
  "C-c o" "find entity")

(defun prilepp/read-entity-link (prompt)
  "Prompt across all entities (like `prilepp/find-entity') and return an
org link string for the pick, without opening/visiting anything. Only
existing entities can be selected — type a new name to create it first
via `prilepp/find-entity', then call this again."
  (let* ((sources (prilepp/entity-sources))
         (vec (vconcat sources))
         (keymap (let ((m (make-sparse-keymap)))
                   (define-key m (kbd "RET")
                     (lambda ()
                       (interactive)
                       (let ((cand (vertico--candidate)))
                         (if (and cand (not (string-blank-p cand))
                                  (consult--tofu-p (aref cand (1- (length cand)))))
                             (throw 'prilepp-read-entity-link
                                    (cons (consult--tofu-strip cand)
                                          (consult--multi-source vec cand)))
                           (user-error "Bitte eine bestehende Entität auswählen")))))
                   m))
         (result (catch 'prilepp-read-entity-link
                   (consult--multi sources :keymap keymap :prompt prompt)
                   nil)))
    (unless result (user-error "Kein Ziel ausgewählt"))
    (funcall (plist-get (cdr result) :link) (car result))))

(defun prilepp/waiting-for-prompt ()
  "When a heading in an actions or project file is set to WAITING, prompt
for an entity to link to (\"what is this waiting on\") and store it as
the WAITING_FOR property."
  (when (and (equal org-state "WAITING")
             buffer-file-name
             (or (file-in-directory-p buffer-file-name (expand-file-name prilepp/actions-directory))
                 (file-in-directory-p buffer-file-name (expand-file-name prilepp/proj-directory))))
    (org-entry-put (point) "WAITING_FOR" (prilepp/read-entity-link "Worauf wird gewartet: "))))

(add-hook 'org-after-todo-state-change-hook #'prilepp/waiting-for-prompt)

(provide 'init-find-entity)
;;; init-find-entity.el ends here
