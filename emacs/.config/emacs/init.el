(setq gc-cons-threshold (* 128 1024 1024)
      read-process-output-max (* 3 1024 1024)
      inhibit-startup-screen t
      initial-scratch-message nil
      native-comp-async-report-warnings-errors nil
      bidi-display-reordering nil
      bidi-paragraph-direction 'left-to-right)

(setq debug-on-error t)
(setq frame-resize-pixelwise t)

(delete-selection-mode 1)
(tool-bar-mode 0)
(scroll-bar-mode 0)

 ;; Font setup: JetBrains Mono
 (set-face-attribute 'default nil
                     :font "JetBrainsMono Nerd Font Mono"
                    :height 150    ;; 100 = 10pt; tweak to your taste
                    :weight 'regular)
(set-face-attribute 'fixed-pitch nil :font "JetBrainsMono Nerd Font Mono" :height 150)
(set-face-attribute 'variable-pitch nil :font "JetBrainsMono Nerd Font Mono" :height 150)

(add-hook 'prog-mode-hook
          (lambda ()
	    (setq-local display-line-numbers 'relative)
	    (line-number-mode t)
            (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
            (set-face-attribute 'font-lock-keyword-face nil :weight 'bold)))

(require 'package)
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(unless package--initialized (package-initialize))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)


(use-package gruvbox-theme
  :init (load-theme 'gruvbox-dark-medium t))

(use-package no-littering
  :config
  ;; Put autosaves, backups, etc. in ~/.emacs.d/var and ~/.emacs.d/etc
  (no-littering-theme-backups)
  (setq custom-file (no-littering-expand-etc-file-name "custom.el")))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :ensure t
  :init
  (setq exec-path-from-shell-variables '("PATH" "MANPATH"))
  :config
  (exec-path-from-shell-initialize))

(use-package vertico :init (vertico-mode 1))
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
(use-package savehist :init (savehist-mode 1))
(use-package orderless
  :init (setq completion-styles '(orderless basic)
              completion-category-defaults nil
              completion-category-overrides '((file (styles basic partial-completion)))))
(use-package marginalia :init (marginalia-mode 1))
(use-package consult
  :config
  (global-set-key (kbd "C-x b") 'consult-buffer)
 ) 

(use-package corfu
  :init (global-corfu-mode)
  :config (setq corfu-auto t
                corfu-auto-delay 0.05
                corfu-auto-prefix 1
                corfu-quit-no-match 'separator)
  )
(use-package cape
  :after corfu
  :config
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

(use-package pdf-tools
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-page)
  ;; Enable midnight mode for a Gruvbox-like dark PDF background
  (setq pdf-view-midnight-colors '("#ebdbb2" . "#282828"))
  (add-hook 'pdf-view-mode-hook #'pdf-view-midnight-minor-mode)
  ;; More natural scrolling
  (add-hook 'pdf-view-mode-hook #'pdf-view-fit-width-to-window))

;; LaTeX powerhouse
(use-package auctex
  :ensure t
  :mode ("\\.tex\\'" . LaTeX-mode)     ;; ensure AUCTeX takes over .tex files
  :config
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-PDF-mode t)

  ;; View via PDF Tools + SyncTeX
  (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
        TeX-source-correlate-start-server t)
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)
(add-hook 'TeX-mode-hook
          (lambda ()
	    (setq-local display-line-numbers 'relative)
	    (setq-local TeX-fold-auto t)
	    (TeX-fold-mode 1)
            (setq prettify-symbols-alist
                  (append tex--prettify-symbols-alist prettify-symbols-alist))
            (prettify-symbols-mode 1)))
)

;; --- Remove the broken CAPF composition --------------------------------------
;; Your original code tried to combine an internal prettify function as a CAPF.
;; Use a simple, solid CAPF stack instead:
(defun my/latex-capf ()
  (setq-local completion-at-point-functions
              (list #'TeX--completion-at-point
                    #'cape-tex
                    #'cape-dabbrev)))

(add-hook 'LaTeX-mode-hook #'my/latex-capf)

;; --- Optional: cdlatex plays fine with the above ------------------------------
(use-package cdlatex
  :hook (LaTeX-mode . cdlatex-mode)
  :config
  (setq cdlatex-use-dollar-to-ensure-math t)
  (with-eval-after-load 'cdlatex
    (add-to-list 'cdlatex-math-modify-alist
		 '(?B "\\mathbb" nil t nil nil))))

;; --- Optional: nice one-key “compile all” and “view” --------------------------
(with-eval-after-load 'tex
  (define-key TeX-mode-map (kbd "C-c C-a") #'TeX-command-run-all)
  (define-key TeX-mode-map (kbd "C-c C-v") #'TeX-view))

;; Snippets (a few LaTeX helpers)
(use-package yasnippet
  :hook ((text-mode prog-mode LaTeX-mode) . yas-minor-mode)
  :config (use-package yasnippet-snippets))

;; RefTeX for citations, labels, cross-refs
(use-package reftex
  :hook (LaTeX-mode . turn-on-reftex)
  :config (setq reftex-plug-into-AUCTeX t))

;; Corfu + CAPE sources tuned for LaTeX (AUCTeX already provides capf)
(defun my/latex-setup ()
  "My fast LaTeX setup."
  ;; Make completion good in LaTeX buffers
  (setq-local completion-at-point-functions
              (list
               (cape-capf-super
                #'tex--prettify-symbols-compose-region
                #'TeX-completion-at-point
                #'cape-tex
                #'cape-dabbrev)))
  ;; Automatically insert pairs like \left( \right)
  (electric-pair-local-mode 1)
  ;; Spellcheck in text, but keep it light
  (when (executable-find "aspell")
    (ispell-change-dictionary "en_US" t)
    (flyspell-mode 1)))

;; Convenience: compile & view keys
(with-eval-after-load 'tex
  (define-key TeX-mode-map (kbd "C-c C-a") #'TeX-command-run-all) ;; compile everything
  (define-key TeX-mode-map (kbd "C-c C-v") #'TeX-view))

(use-package evil
  :init
  (setq evil-want-keybinding nil          ; we'll use evil-collection
        evil-want-C-u-scroll t
        evil-want-C-i-jump t
        evil-undo-system 'undo-redo)      ; Emacs 28+ native undo/redo
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package god-mode
  :after evil
  :init
  ;; Nice behavior in isearch/minibuffer
  (add-hook 'minibuffer-setup-hook (lambda () (setq-local god-local-mode nil)))
  :config
  ;; Enable translation so regular keys map to C-/M- variants when active
  ;; Escape disables god-local-mode if you ever toggle it

  ;; One-shot God Mode on Space in Evil normal/visual states
  ;; Press SPC, then e.g. "f" for C-f, "g" for C-g, "x" for M-x, etc.
  (define-key evil-normal-state-map (kbd "SPC") #'god-execute-with-current-bindings)
  (define-key evil-visual-state-map (kbd "SPC") #'god-execute-with-current-bindings)

  ;; Optional: if you sometimes want a real toggle, uncomment this
  ;; (with-eval-after-load 'evil
  ;;   (evil-define-key 'normal global-map (kbd "g SPC") #'god-local-mode))
  )

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package magit)

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
  (obsidian-directory "~/Documents/Obsidian/conspects/MainVault/MainVault/")
  ;; Default location for new notes from `obsidian-capture'
  (obsidian-inbox-directory "Inbox")
  ;; Useful if you're going to be using wiki links
  (markdown-enable-wiki-links t)

  ;; These bindings are only suggestions; it's okay to use other bindings
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

  

;; Keep GC sane after startup
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold (* 32 1024 1024))))
;;;; -------------------------------------------------------------------------

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(auctex cape cdlatex consult corfu gruvbox-theme marginalia
	    no-littering orderless vertico yasnippet
	    yasnippet-snippets)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
