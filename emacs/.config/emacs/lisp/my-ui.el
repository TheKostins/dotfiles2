;;; my-ui.el --- Theme, paths, and UI integration -*- lexical-binding: t; -*-

(require 'use-package)

(use-package gruvbox-theme
  :init
  (load-theme 'gruvbox-dark-medium t))

(use-package no-littering
  :config
  ;; Put autosaves, backups, etc. in ~/.emacs.d/var and ~/.emacs.d/etc
  (no-littering-theme-backups)
  (setq create-lockfiles nil)
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  (load custom-file 'noerror 'nomessage))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :ensure t
  :init
  (setq exec-path-from-shell-variables '("PATH" "MANPATH"))
  :config
  (exec-path-from-shell-initialize))

(provide 'my-ui)

;;; my-ui.el ends here
