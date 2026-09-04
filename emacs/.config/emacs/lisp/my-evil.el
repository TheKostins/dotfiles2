;;; my-evil.el --- Evil and modal editing setup -*- lexical-binding: t; -*-

(require 'use-package)

(use-package evil
  :init
  (setq evil-want-keybinding nil
        evil-want-C-i-jump t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(use-package evil-numbers
  :after evil
  :bind (:map evil-normal-state-map
              ("g+" . evil-numbers/inc-at-pt)
              ("g-" . evil-numbers/dec-at-pt)))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

;; Tree-sitter powered text objects/motions, equivalent to
;; nvim-treesitter-textobjects. Works against the built-in `treesit' parsers
;; already installed for rust-ts-mode, c-ts-mode, c++-ts-mode, python-ts-mode,
;; and odin-ts-mode -- no extra grammar setup needed.
(use-package evil-textobj-tree-sitter
  :after evil
  :config
  ;; `evil-textobj-tree-sitter-get-textobj' is a macro that requires a
  ;; literal group string (it inspects `GROUP' at macro-expansion time), so
  ;; these calls can't be generated in a loop.
  (define-key evil-outer-text-objects-map "f" (evil-textobj-tree-sitter-get-textobj "function.outer"))
  (define-key evil-inner-text-objects-map "f" (evil-textobj-tree-sitter-get-textobj "function.inner"))
  (define-key evil-outer-text-objects-map "c" (evil-textobj-tree-sitter-get-textobj "class.outer"))
  (define-key evil-inner-text-objects-map "c" (evil-textobj-tree-sitter-get-textobj "class.inner"))
  (define-key evil-outer-text-objects-map "a" (evil-textobj-tree-sitter-get-textobj "parameter.outer"))
  (define-key evil-inner-text-objects-map "a" (evil-textobj-tree-sitter-get-textobj "parameter.inner"))
  (define-key evil-outer-text-objects-map "l" (evil-textobj-tree-sitter-get-textobj "loop.outer"))
  (define-key evil-inner-text-objects-map "l" (evil-textobj-tree-sitter-get-textobj "loop.inner"))
  (define-key evil-outer-text-objects-map "i" (evil-textobj-tree-sitter-get-textobj "conditional.outer"))
  (define-key evil-inner-text-objects-map "i" (evil-textobj-tree-sitter-get-textobj "conditional.inner"))
  (define-key evil-outer-text-objects-map "C" (evil-textobj-tree-sitter-get-textobj "comment.outer"))
  (define-key evil-inner-text-objects-map "C" (evil-textobj-tree-sitter-get-textobj "comment.inner"))
  ;; `]]'/`[[' are left alone (Evil's own section motion); `c' keeps the
  ;; mnemonic used above for class instead of nvim-treesitter-textobjects'
  ;; default `]]'/`[['.
  (define-key evil-normal-state-map (kbd "]f")
              (lambda () (interactive) (evil-textobj-tree-sitter-goto-textobj "function.outer")))
  (define-key evil-normal-state-map (kbd "[f")
              (lambda () (interactive) (evil-textobj-tree-sitter-goto-textobj "function.outer" t)))
  (define-key evil-normal-state-map (kbd "]c")
              (lambda () (interactive) (evil-textobj-tree-sitter-goto-textobj "class.outer")))
  (define-key evil-normal-state-map (kbd "[c")
              (lambda () (interactive) (evil-textobj-tree-sitter-goto-textobj "class.outer" t))))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode 1))

(use-package evil-mc
  :after evil
  :commands (evil-mc-make-and-goto-next-match
             evil-mc-make-and-goto-prev-match
             evil-mc-make-all-cursors
             evil-mc-make-cursor-move-next-line
             evil-mc-make-cursor-move-prev-line
             evil-mc-skip-and-goto-next-match
             evil-mc-skip-and-goto-prev-match
             evil-mc-undo-last-added-cursor
             evil-mc-undo-all-cursors
             evil-mc-pause-cursors
             evil-mc-resume-cursors)
  :bind (:map evil-normal-state-map
              ("C-c m n" . evil-mc-make-and-goto-next-match)
              ("C-c m p" . evil-mc-make-and-goto-prev-match)
              ("C-c m a" . evil-mc-make-all-cursors)
              ("C-c m j" . evil-mc-make-cursor-move-next-line)
              ("C-c m k" . evil-mc-make-cursor-move-prev-line)
              ("C-c m N" . evil-mc-skip-and-goto-next-match)
              ("C-c m P" . evil-mc-skip-and-goto-prev-match)
              ("C-c m u" . evil-mc-undo-last-added-cursor)
              ("C-c m U" . evil-mc-undo-all-cursors)
              ("C-c m SPC" . evil-mc-pause-cursors)
              ("C-c m RET" . evil-mc-resume-cursors)
         :map evil-visual-state-map
              ("C-c m n" . evil-mc-make-and-goto-next-match)
              ("C-c m p" . evil-mc-make-and-goto-prev-match)
              ("C-c m a" . evil-mc-make-all-cursors))
  :config
  (global-evil-mc-mode 1)
  (with-eval-after-load 'which-key
    (which-key-add-key-based-replacements "C-c m" "evil-mc")))

(use-package god-mode
  :after evil
  :init
  ;; Nice behavior in isearch/minibuffer
  (add-hook 'minibuffer-setup-hook (lambda () (setq-local god-local-mode nil)))
  :config
  ;; One-shot God Mode on Space in Evil normal/visual states
  (define-key evil-normal-state-map (kbd "SPC") #'god-execute-with-current-bindings)
  (define-key evil-visual-state-map (kbd "SPC") #'god-execute-with-current-bindings))

(provide 'my-evil)

;;; my-evil.el ends here
