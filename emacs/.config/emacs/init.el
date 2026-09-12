;;; init.el --- Konstantin's Emacs config -*- lexical-binding: t; -*-

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'my-core)
(require 'my-packages)
(require 'my-ui)
(require 'my-completion)
(require 'my-eglot)
(require 'my-python)
(require 'my-pdf)
(require 'my-latex)
(require 'my-latex-cdlatex)
(require 'my-evil)
(require 'my-input)
(require 'my-tools)
(require 'my-odin)
(require 'my-cpp)
(require 'my-rust)
(require 'my-org)

;;; init.el ends here
