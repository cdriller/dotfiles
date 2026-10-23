;;; init.el --- Entry point, loads all modules from lisp/ -*- lexical-binding: t; -*-

;;; Code:

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'init-paths)
(require 'init-packages)
(require 'init-basics)
(require 'init-completion)
(require 'init-org)
(require 'init-utils)
(require 'init-gtd-list-types)
(require 'init-gtd-lists)
(require 'init-files)
(require 'init-routines)
(require 'init-gtd-list-archive)
(require 'init-contacts)
(require 'init-calendar)
(require 'init-find-entity)
(require 'init-dashboard)

;;; init.el ends here
