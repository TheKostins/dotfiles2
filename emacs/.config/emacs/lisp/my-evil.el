;;; my-evil.el --- Evil and modal editing setup -*- lexical-binding: t; -*-

(require 'use-package)

(use-package evil
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(use-package evil-numbers
  :after evil
  :bind (:map evil-normal-state-map
              ("C-a" . evil-numbers/inc-at-pt)
              ("C-d" . evil-numbers/dec-at-pt)))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

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
