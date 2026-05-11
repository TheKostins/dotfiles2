;;; init.el --- Konstantin's Emacs config -*- lexical-binding: t; -*-
(setq debug-on-error t)
(setq frame-resize-pixelwise t)

(setq my/font  "Pixel Code")

 ;; Font setup: JetBrains Mono
 (set-face-attribute 'default nil
                     :font my/font
                    :height 150    ;; 100 = 10pt; tweak to your taste
                    :weight 'regular)
(set-face-attribute 'fixed-pitch nil :font my/font :height 150)
(set-face-attribute 'variable-pitch nil :font my/font :height 150)

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
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  (load custom-file 'noerror 'nomessage))

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
  :bind (:map global-map
	      ("C-x b" . consult-buffer)
	      ("C-x C-b" . consult-buffer)
	      ("C-s C-l" . consult-line)
	      ("C-s C-g" . consult-ripgrep))
  :init
  (dolist (key '("C-s" "C-x b"))
    (unbind-key (kbd key)))) 

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
  (setq TeX-parse-self t
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

(use-package auctex-latexmk
  :custom
   (auctex-latexmk-inherit-TeX-PDF-mode t)
   :config
   (auctex-latexmk-setup))



;;;; ---------------- LaTeX: single setup (corfu + cape + cdlatex + spell EN/RU)

;; 1) TAB: prefer cdlatex expansion
(defun my/latex-tab ()
  "TAB in LaTeX: prefer cdlatex expansion, else indent."
  (interactive)
  (if (and (bound-and-true-p cdlatex-mode)
           (fboundp 'cdlatex-tab))
      (cdlatex-tab)
    (indent-for-tab-command)))

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (local-set-key (kbd "TAB")   #'my/latex-tab)
            (local-set-key (kbd "<tab>") #'my/latex-tab)))
;; Optional: prevent Corfu popup from stealing TAB
(with-eval-after-load 'corfu
  (define-key corfu-map (kbd "TAB") nil)
  (define-key corfu-map (kbd "<tab>") nil))

;; 2) Spell: EN+RU (auto)
;; Requires hunspell dictionaries OR aspell with ru/en.

;; Hunspell + EN/RU (один процесс, multi-dict)
(with-eval-after-load 'ispell
  (setq ispell-program-name "hunspell"
        ispell-really-hunspell t
        ;; ключевой момент: Emacs должен видеть multi-dict как "словарь"
        ispell-dictionary "en_US,ru_RU"
        ;; hunspell pipe mode + utf-8
        ispell-extra-args '("-a" "-i" "utf-8"))

  ;; ВАЖНО по документации/практике: сначала параметры, потом multi-dict
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "en_US,ru_RU"))

(defun my/latex-spell-setup ()
  "Flyspell in LaTeX with Hunspell EN/RU."
  (when (executable-find "hunspell")
    (flyspell-mode 1)))

(use-package company-spell
  :ensure t
  :config
  ;; use hunspell
  (setq company-spell-command "hunspell"
        company-spell-args "-a -i utf-8 -d en_US,ru_RU"))

(defun my/cape-spell-capf ()
  "CAPF for spell suggestions via hunspell (company-spell) in text, not math."
  (when (and (derived-mode-p 'latex-mode)
             (fboundp 'texmathp)
             (not (texmathp)))
    (funcall (cape-company-to-capf #'company-spell))))

;; 3) Completion stack for LaTeX
(defun my/latex-setup ()
  "My LaTeX setup (completion + pairs + spell)."
  ;; CAPF: AUCTeX first, then cape, then dabbrev
  (setq-local completion-at-point-functions
              (list
               #'TeX--completion-at-point  ; AUCTeX (works in LaTeX-mode)
               #'cape-tex
	       #'my/cape-spell-capf
               #'cape-dabbrev))

  ;; Nice editing
  (electric-pair-local-mode 1)

  ;; Spell EN/RU
  (my/latex-spell-setup))

(add-hook 'LaTeX-mode-hook #'my/latex-setup)

;;;; ------------------------------------------------------------------------

;; --- Optional: cdlatex plays fine with the above ------------------------------
(use-package cdlatex
  :hook (LaTeX-mode . cdlatex-mode)
  :config
  (setq cdlatex-use-dollar-to-ensure-math t)
  (add-to-list 'cdlatex-math-modify-alist
	       '(?B "\\mathbb" nil t nil nil))
  (add-to-list 'cdlatex-math-modify-alist
	       '(?- "\\overline" nil t nil nil))
  (add-to-list 'cdlatex-command-alist
   	       '("mk" "Insert $...$" "$?$" cdlatex-position-cursor nil t nil) t)
  (add-to-list 'cdlatex-command-alist
	       '("dm" "Insert \\[...\\]" "\\[\n?\n\\]" cdlatex-position-cursor nil t nil) t)
  (add-to-list 'cdlatex-command-alist
	       '("pb" "Insert \\Pb(...)" "\\Pb(?)" cdlatex-position-cursor nil nil t) t)

  (add-to-list 'cdlatex-math-symbol-alist
	       '(?& ("\\cap" "\\wedge")))

  (defun my/cdlatex-add-env (abbr env &optional autolabel optarg)
    "Register a CDLaTeX environment ENV and an abbreviation ABBR.

- Adds ENV template to `cdlatex-env-alist` (for `cdlatex-environment` / C-c {).
- Adds ABBR to `cdlatex-command-alist` so ABBR<TAB> inserts ENV.

AUTOLABEL: if non-nil, insert \"AUTOLABEL\" line (RefTeX label hook).
OPTARG:    if non-nil, add optional argument placeholder like [ ? ]."
    (let ((template (concat "\\begin{" env "}"
                            (when optarg "[?]")
                            "\n"
                            (when autolabel "AUTOLABEL\n")
			    (if optarg "\n" "?\n")
                            "\\end{" env "}\n")))
      ;; 1) environment template (keyed by ENV)
      (add-to-list 'cdlatex-env-alist (list env template nil) t)

      ;; 2) abbreviation (keyed by ABBR)
      ;; cdlatex-command-alist entry format per README:
      ;; (ABBR "Desc" "" cdlatex-environment (ENV) t nil)
      (add-to-list 'cdlatex-command-alist
                   (list abbr
			 (format "Insert %s env" env)
			 ""
			 #'cdlatex-environment
			 (list env)
			 t
			 nil)
                   t)))
  ;; Теоремные окружения
  (my/cdlatex-add-env "thm"  "theorem" nil t)
  (my/cdlatex-add-env "lem"  "lemma" nil t)
  (my/cdlatex-add-env "cor"  "corollary")
  (my/cdlatex-add-env "def"  "definition" nil t)
  (my/cdlatex-add-env "ex"   "example")
  (my/cdlatex-add-env "rem"  "remark" nil t)

  ;; Proof (без аргументов)
  (my/cdlatex-add-env "prf"   "proof")

  ;; Математические
  (my/cdlatex-add-env "al"   "align")
  (my/cdlatex-add-env "ga"   "gather")

  ;; Если ты сделал tcolorbox окружения: idea / pitfall / intuition / proofsketch
  (my/cdlatex-add-env "idea" "idea")
  (my/cdlatex-add-env "pit"  "pitfall")
  (my/cdlatex-add-env "int"  "intuition")
  (my/cdlatex-add-env "ps"   "proofsketch")

  (with-eval-after-load 'evil
    (add-hook 'LaTeX-mode-hook
              (lambda ()
		(evil-local-set-key 'insert (kbd "TAB")   #'my/latex-tab)
		(evil-local-set-key 'insert (kbd "<tab>") #'my/latex-tab))))
  )

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

(use-package evil-numbers
  :after evil
  :bind (:map evil-normal-state-map
              ("C-a" . evil-numbers/inc-at-pt)
              ("C-d" . evil-numbers/dec-at-pt)))

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
  (obsidian-directory "~/Documents/Obsidian/MainVault/MainVault/")
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

(use-package just-mode)

