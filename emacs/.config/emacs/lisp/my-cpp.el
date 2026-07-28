;;; my-cpp.el --- C/C++ development via tree-sitter and eglot -*- lexical-binding: t; -*-

(require 'use-package)

;; Tree-sitter major modes (auto-remap c-mode/c++-mode when grammars are installed)
;; M-x treesit-install-language-grammar RET c   RET
;; M-x treesit-install-language-grammar RET cpp RET
(use-package c-ts-mode
  :ensure nil
  :init
  (add-to-list 'treesit-language-source-alist
               '(c "https://github.com/tree-sitter/tree-sitter-c"))
  (add-to-list 'treesit-language-source-alist
               '(cpp "https://github.com/tree-sitter/tree-sitter-cpp"))
  :custom
  (c-ts-mode-indent-offset 4))

;; LSP via built-in eglot (server: clangd)
;; For accurate diagnostics/completion, generate compile_commands.json:
;;   cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
;; or `bear -- make` for non-CMake projects.
(use-package eglot
  :ensure nil
  :hook ((c-ts-mode   . eglot-ensure)
         (c++-ts-mode . eglot-ensure)))

(use-package cmake-mode
  :mode ("CMakeLists\\.txt\\'" "\\.cmake\\'"))

;; Format on save via clangd's built-in formatting (clang-format under the hood)
(use-package clang-format
  :after c-ts-mode
  :bind (:map c-ts-mode-map
              ("C-c f" . clang-format-buffer)
         :map c++-ts-mode-map
              ("C-c f" . clang-format-buffer)))

(provide 'my-cpp)

;;; my-cpp.el ends here
