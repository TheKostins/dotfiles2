;;; my-rust.el --- Rust development via tree-sitter and eglot -*- lexical-binding: t; -*-

(require 'use-package)

;; Tree-sitter major mode (auto-remaps rust-mode when the grammar is installed)
;; M-x treesit-install-language-grammar RET rust RET
(use-package rust-ts-mode
  :ensure nil
  :init
  (add-to-list 'treesit-language-source-alist
               '(rust "https://github.com/tree-sitter/tree-sitter-rust")))

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
