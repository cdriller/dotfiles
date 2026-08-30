;;; init-packages.el --- Package manager bootstrap -*- lexical-binding: t; -*-

;;; Commentary:
;; Sets up package.el/MELPA and ensures use-package is available.

;;; Code:

(setq package-install-upgrade-built-in t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Install use-package if not present
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)  ; auto-install all packages

(provide 'init-packages)
;;; init-packages.el ends here
