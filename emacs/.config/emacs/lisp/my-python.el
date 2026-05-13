;;; my-python.el --- Python and Jupyter notebook support -*- lexical-binding: t; -*-

(require 'use-package)

(use-package python
  :ensure nil
  :custom
  (python-indent-offset 4)
  (python-shell-interpreter "ipython")
  (python-shell-interpreter-args "--simple-prompt --no-color-info"))

;; Virtual environment management
;; M-x pyvenv-activate  → point at any venv directory
;; M-x pyvenv-workon    → pick from virtualenvwrapper WORKON_HOME
(use-package pyvenv
  :hook (python-mode . pyvenv-mode)
  :config
  (add-hook 'pyvenv-post-activate-hooks
            (lambda ()
              (when (eglot-current-server)
                (call-interactively #'eglot)))))

;; LSP via built-in eglot (server: basedpyright / pyright / pylsp)
;; Completion integrates automatically with Corfu via the CAPF mechanism.
;; Eglot re-launches after pyvenv-activate so it inherits the new venv's PATH.
(use-package eglot
  :ensure nil
  :hook ((python-mode    . eglot-ensure)
         (python-ts-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t))

;; Jupyter notebook client
(use-package ein
  :defer t
  :custom
  (ein:output-area-inlined-images t)
  (ein:slice-image t)
  :config
  (with-eval-after-load 'which-key
    (which-key-add-key-based-replacements "C-c !" "ein")))

(provide 'my-python)

;;; my-python.el ends here
