;;; my-ui.el --- Theme, paths, and UI integration -*- lexical-binding: t; -*-

(require 'use-package)

(use-package gruvbox-theme
  :init
  (load-theme 'gruvbox-dark-medium t)
  :config
  ;; The upstream `gruvbox-theme' package predates Emacs 29's tree-sitter
  ;; font-lock faces (used by rust-ts-mode, c-ts-mode, etc.), so anything
  ;; mapped only to those faces renders unstyled. Fill the gap with colors
  ;; ported from the equivalent @-capture-group mapping in the gruvbox.nvim
  ;; colorscheme (nvim/.config/nvim/lua/plugins/gruvbox.lua's `@variable',
  ;; `@property', `@operator', etc.), so tree-sitter buffers look the same
  ;; across both editors.
  (custom-theme-set-faces
   'gruvbox-dark-medium
   '(font-lock-bracket-face       ((t (:foreground "#fe8019"))))       ; @punctuation.bracket
   '(font-lock-delimiter-face     ((t (:foreground "#fe8019"))))       ; @punctuation.delimiter
   '(font-lock-operator-face      ((t (:foreground "#fe8019"))))       ; @operator
   '(font-lock-escape-face        ((t (:foreground "#fe8019"))))       ; @string.escape
   '(font-lock-preprocessor-face  ((t (:foreground "#8ec07c"))))       ; @keyword.directive, attributes
   '(font-lock-function-call-face ((t (:foreground "#b8bb26" :bold t)))) ; @function.call
   '(font-lock-property-name-face ((t (:foreground "#83a598"))))       ; @property (declaration)
   '(font-lock-property-use-face  ((t (:foreground "#83a598"))))       ; @property (use, e.g. `foo.bar')
   ;; nvim's gruvbox doesn't split variable declare/use into separate
   ;; colors; match this theme's own `font-lock-variable-name-face' (blue)
   ;; here instead of nvim's plain foreground, so a variable looks the same
   ;; whether declared or used.
   '(font-lock-variable-use-face  ((t (:foreground "#83a598"))))
   '(font-lock-doc-face           ((t (:inherit font-lock-comment-face)))))
  (enable-theme 'gruvbox-dark-medium))

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
