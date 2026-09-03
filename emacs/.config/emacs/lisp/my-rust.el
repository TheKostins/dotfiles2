;;; my-rust.el --- Rust development via tree-sitter and eglot -*- lexical-binding: t; -*-

(require 'use-package)

;; Tree-sitter major mode (auto-remaps rust-mode when the grammar is installed)
;; M-x treesit-install-language-grammar RET rust RET
(use-package rust-ts-mode
  :ensure nil
  :init
  (add-to-list 'treesit-language-source-alist
               '(rust "https://github.com/tree-sitter/tree-sitter-rust"))
  :config
  ;; rust-ts-mode colors a match arm's uppercase pattern the same as any
  ;; other reference to it (PascalCase enum variant -> font-lock-type-face
  ;; via `Enum::Variant', bare identifier -> font-lock-variable-name-face,
  ;; treating it as a fresh binding). gruvbox.nvim's rust query special-cases
  ;; match arms: any uppercase pattern there -- bare (`MAX => ...') or after
  ;; `::' (`Color::Red => ...') -- is a constant/variant match, not a
  ;; binding, and gets colored as a constant. Layer that rule on top with
  ;; :override t so it wins over rust-ts-mode's own assignment; lowercase
  ;; catch-all bindings (`x => ...') are untouched since they fail the
  ;; uppercase guard.
  ;; (add-hook 'rust-ts-mode-hook
  ;;           (lambda ()
  ;;             (setq-local
  ;;              treesit-font-lock-settings
  ;;              (append treesit-font-lock-settings
  ;;                      (treesit-font-lock-rules
  ;;                       :language 'rust
  ;;                       :feature 'type
  ;;                       :override t
  ;;                       '((match_arm
  ;;                          pattern: (match_pattern (identifier) @font-lock-constant-face)
  ;;                          (:match "\\`[A-Z]" @font-lock-constant-face))
  ;;                         (match_arm
  ;;                          pattern: (match_pattern
  ;;                                    (scoped_identifier name: (identifier) @font-lock-constant-face))
  ;;                          (:match "\\`[A-Z]" @font-lock-constant-face))))))
  ;;             (font-lock-flush)))
  )

;; LSP via built-in eglot (server: rust-analyzer, eglot's default for rust-ts-mode)
;; For clippy diagnostics instead of plain `cargo check`:
;;   (setq-default eglot-workspace-configuration
;;                 '(:rust-analyzer (:check (:command "clippy"))))
(use-package eglot
  :ensure nil
  :hook (rust-ts-mode . eglot-ensure)
  :bind (:map rust-ts-mode-map
              ("C-c f" . eglot-format-buffer)))

(provide 'my-rust)

;;; my-rust.el ends here
