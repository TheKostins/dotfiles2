;;; my-latex.el --- LaTeX setup -*- lexical-binding: t; -*-

(require 'use-package)
(require 'cape)

;; LaTeX powerhouse
(use-package auctex
  :ensure t
  :mode ("\\.tex\\'" . LaTeX-mode)
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
              (prettify-symbols-mode 1))))

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
            (local-set-key (kbd "TAB") #'my/latex-tab)
            (local-set-key (kbd "<tab>") #'my/latex-tab)))

;; Optional: prevent Corfu popup from stealing TAB
(with-eval-after-load 'corfu
  (define-key corfu-map (kbd "TAB") nil)
  (define-key corfu-map (kbd "<tab>") nil))

;; 2) Spell: EN+RU (auto)
;; Requires hunspell dictionaries OR aspell with ru/en.

;; Hunspell + EN/RU (one process, multi-dict)
(with-eval-after-load 'ispell
  (setq ispell-program-name "hunspell"
        ispell-really-hunspell t
        ;; Emacs should see multi-dict as the dictionary.
        ispell-dictionary "en_US,ru_RU"
        ;; Hunspell pipe mode + utf-8.
        ispell-extra-args '("-a" "-i" "utf-8"))

  ;; Set params before adding the multi-dict.
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
              (delq nil
                    (list
                     (when (fboundp 'TeX--completion-at-point)
                       #'TeX--completion-at-point)
                     (when (fboundp 'cape-tex)
                       #'cape-tex)
                     #'my/cape-spell-capf
                     (when (fboundp 'cape-dabbrev)
                       #'cape-dabbrev))))

  ;; Nice editing
  (electric-pair-local-mode 1)

  ;; Spell EN/RU
  (my/latex-spell-setup))

(add-hook 'LaTeX-mode-hook #'my/latex-setup)

;; --- Optional: nice one-key compile all and view --------------------------
(with-eval-after-load 'tex
  (define-key TeX-mode-map (kbd "C-c C-a") #'TeX-command-run-all)
  (define-key TeX-mode-map (kbd "C-c C-v") #'TeX-view))

;; Snippets (a few LaTeX helpers)
(use-package yasnippet
  :hook ((text-mode prog-mode LaTeX-mode) . yas-minor-mode)
  :config
  (use-package yasnippet-snippets))

;; RefTeX for citations, labels, cross-refs
(use-package reftex
  :hook (LaTeX-mode . turn-on-reftex)
  :config
  (setq reftex-plug-into-AUCTeX t))

(provide 'my-latex)

;;; my-latex.el ends here
