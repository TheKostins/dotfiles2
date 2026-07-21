;;; my-odin.el --- Odin language support via tree-sitter -*- lexical-binding: t; -*-

(require 'use-package)

(use-package odin-ts-mode
  :vc (:url "https://github.com/Sampie159/odin-ts-mode" :rev :newest)
  :init
  (add-to-list 'treesit-language-source-alist
               '(odin "https://github.com/tree-sitter-grammars/tree-sitter-odin"))
  :mode "\\.odin\\'")

(provide 'my-odin)

;;; my-odin.el ends here
