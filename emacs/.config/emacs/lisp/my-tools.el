;;; my-tools.el --- Miscellaneous packages and modes -*- lexical-binding: t; -*-

(require 'use-package)

(use-package which-key
  :ensure nil
  :init
  (which-key-mode 1)
  :config
  (setq which-key-idle-delay 0.4))

(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package magit)

(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

(use-package wgrep)

(use-package diff-hl
  :hook ((prog-mode text-mode dired-mode) . diff-hl-mode)
  :config
  (diff-hl-flydiff-mode 1))

(use-package diredfl
  :config
  (diredfl-global-mode))

(use-package markdown-mode)

(use-package obsidian
  :config
  (global-obsidian-mode t)
  (obsidian-backlinks-mode t)
  :custom
  ;; location of obsidian vault
  (obsidian-directory "~/Documents/Obsidian/MainVault/MainVault/")
  ;; Default location for new notes from `obsidian-capture'
  (obsidian-inbox-directory "Inbox")
  ;; Useful if you're going to be using wiki links
  (markdown-enable-wiki-links t)
  :bind (:map obsidian-mode-map
              ;; Create note
              ("C-c C-n" . obsidian-capture)
              ;; If you prefer you can use `obsidian-insert-wikilink'
              ("C-c C-l" . obsidian-insert-link)
              ;; Open file pointed to by link at point
              ("C-c C-o" . obsidian-follow-link-at-point)
              ;; Open a different note from vault
              ("C-c C-p" . obsidian-jump)
              ;; Follow a backlink for the current file
              ("C-c C-b" . obsidian-backlink-jump)))

(use-package just-mode)

(provide 'my-tools)

;;; my-tools.el ends here
