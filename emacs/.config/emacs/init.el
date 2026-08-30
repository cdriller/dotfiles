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

;;; init.el ends here
