;;; init.el --- Entry point, loads all modules from lisp/ -*- lexical-binding: t; -*-

;;; Code:

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'init-paths)
(require 'init-packages)
(require 'init-basics)
(require 'init-completion)
(require 'init-org)
(require 'init-files)
(require 'init-projects)
(require 'init-contacts)
(require 'init-calendar)
(require 'init-find-entity)
(require 'init-dashboard)

;;; init.el ends here
