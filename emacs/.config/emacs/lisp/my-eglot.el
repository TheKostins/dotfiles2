;;; my-eglot.el --- Common eglot (LSP) settings -*- lexical-binding: t; -*-

(require 'use-package)

;; Language-specific setup (hooks that enable eglot-ensure, per-mode format
;; keys) lives in each language module (my-python, my-cpp, my-rust, ...).
;; This module holds only the bindings and options that apply uniformly
;; across every eglot-managed buffer.
(use-package eglot
  :ensure nil
  :custom
  (eglot-autoshutdown t)
  :bind (:map eglot-mode-map
              ("C-c C-a" . eglot-code-actions)
              ("C-c C-r" . eglot-rename)))

;; Eldoc (hover docs, signature help) in a childframe at point, shown only
;; on demand -- never automatically in the echo area. `eldoc-display-in-buffer'
;; is left in `eldoc-display-functions' so eldoc's fetch cycle keeps the doc
;; buffer fresh in the background (with `interactive' nil it only updates
;; the buffer, it doesn't pop a window); only `eldoc-display-in-echo-area'
;; is dropped so nothing shows until requested. Rebinds evil-collection's
;; eglot "K" (normally `eldoc-doc-buffer') to the childframe version.
(use-package eldoc-box
  :commands eldoc-box-help-at-point
  :init
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (setq-local eldoc-display-functions
                          (remove #'eldoc-display-in-echo-area
                                  eldoc-display-functions))))
  (with-eval-after-load 'evil-collection
    (add-hook 'eglot-managed-mode-hook
              (lambda ()
                (evil-collection-define-key 'normal 'eglot-mode-map
                  "K" #'eldoc-box-help-at-point)))))

;; Show flymake diagnostics inline at the end of the line. Eglot uses
;; flymake as its diagnostics backend by default, so this covers every
;; LSP-managed buffer without any eglot-specific wiring.
(use-package sideline
  :init
  (setq sideline-backends-right '(sideline-flymake)))

(use-package sideline-flymake
  :after sideline
  :hook (flymake-mode . sideline-mode))

(provide 'my-eglot)

;;; my-eglot.el ends here
