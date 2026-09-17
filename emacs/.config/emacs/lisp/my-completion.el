;;; my-completion.el --- Minibuffer and completion setup -*- lexical-binding: t; -*-

(require 'use-package)

(use-package vertico
  :init
  (vertico-mode 1))

(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; Show the minibuffer completion UI (M-x, find-file, etc.) in a centered
;; posframe instead of anchored at the bottom of the frame. Falls back to
;; the normal minibuffer automatically in terminal Emacs, where posframe
;; (child frames) aren't supported.
(use-package vertico-posframe
  :after vertico
  :init
  (vertico-posframe-mode 1))

(use-package savehist
  :init
  (savehist-mode 1))

(declare-function my/russian-stem-regexp "my-russian-stem")

(defun my/orderless-russian-dispatch (component _index _total)
  "Match a Cyrillic COMPONENT by its stem, so any inflected form matches.
`теоремы' finds \"Теорема Байеса\"; ё and е are interchangeable.  Prefix
with `=' for the literal form (see `orderless-affix-dispatch', which runs
first).  Components with Latin letters or punctuation are left alone."
  (when (string-match-p "\\`[а-яёА-ЯЁ]+\\'" component)
    (when-let* ((re (my/russian-stem-regexp component)))
      (cons 'orderless-regexp re))))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion))))
  :config
  (require 'my-russian-stem)
  (add-to-list 'orderless-style-dispatchers #'my/orderless-russian-dispatch t))

(use-package marginalia
  :init
  (marginalia-mode 1))

(use-package project
  :ensure nil
  :bind (:map global-map
              ("C-c p p" . project-switch-project)
              ("C-c p b" . consult-project-buffer)
              ("C-c p f" . consult-find)
              ("C-c p g" . consult-ripgrep)))

(use-package consult
  :bind (:map global-map
              ("C-x b" . consult-buffer)
              ("C-x C-b" . consult-buffer)
              ("C-c C-l" . consult-line)
              ("C-c C-y" . consult-yank-pop)
              ("C-c C-i" . consult-imenu)
              ("C-c C-g" . consult-ripgrep))
  :init
  (unbind-key (kbd "C-x b")))

(use-package embark
  :bind (:map global-map
              ("C-'" . embark-act)
              ("C-;" . embark-dwim)
              ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :init
  (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.05
        corfu-auto-prefix 2
        corfu-quit-no-match 'separator)
  (corfu-popupinfo-mode 1)
  (setq corfu-popupinfo-delay '(0.5 . 0.2)))

(use-package cape
  :after corfu
  :config
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

(provide 'my-completion)

;;; my-completion.el ends here
