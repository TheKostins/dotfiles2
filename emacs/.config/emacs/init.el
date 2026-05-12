;;; init.el --- Konstantin's Emacs config -*- lexical-binding: t; -*-

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'my-core)
(require 'my-packages)
(require 'my-ui)
(require 'my-completion)
(require 'my-pdf)
(require 'my-latex)
(require 'my-evil)
(require 'my-tools)

;;; init.el ends here
