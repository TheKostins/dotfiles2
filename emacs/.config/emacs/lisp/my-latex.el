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
  "TAB in LaTeX: indent at line start, otherwise hand over to CDLaTeX
\(abbreviation expansion, then jumping to the next input spot)."
  (interactive)
  (if (and (bound-and-true-p cdlatex-mode)
           (fboundp 'cdlatex-tab)
           (not (looking-back "^[ \t]*" (line-beginning-position))))
      (cdlatex-tab)
    (indent-for-tab-command)))

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (local-set-key (kbd "TAB") #'my/latex-tab)
            (local-set-key (kbd "<tab>") #'my/latex-tab)))

;; When the Corfu popup is active, TAB should complete the selected
;; candidate.  Otherwise the LaTeX local binding below gives TAB to CDLaTeX.
(declare-function cdlatex-tab "cdlatex")
(declare-function cdlatex--texmathp "cdlatex")

(defun my/cdlatex-abbrev-p ()
  "Non-nil when the word before point is a CDLaTeX abbreviation valid here.
Mirrors the lookup `cdlatex-tab' itself performs (text vs. math flags
included), so callers can decide whether TAB should go to CDLaTeX."
  (when (and (or (bound-and-true-p cdlatex-mode)
                 (bound-and-true-p org-cdlatex-mode))
             (boundp 'cdlatex-command-alist-comb))
    (save-excursion
      (let ((pos (point)))
        (backward-word 1)
        (while (eq (following-char) ?$) (forward-char 1))
        (let ((exp (assoc (buffer-substring-no-properties (point) pos)
                          cdlatex-command-alist-comb)))
          (and exp
               (if (cdlatex--texmathp) (nth 6 exp) (nth 5 exp))
               t))))))

(defun my/cdlatex-active-p ()
  "Non-nil when CDLaTeX is in charge of TAB in this buffer."
  (or (bound-and-true-p cdlatex-mode)
      (bound-and-true-p org-cdlatex-mode)))

(defun my/corfu-tab ()
  "TAB while the Corfu popup is open.
In a CDLaTeX buffer TAB keeps its CDLaTeX meaning whenever that is what
you are most likely after: an abbreviation before point (`suml'), point
inside math, or point right before a closing delimiter (jump out of the
brace).  It completes the candidate only for a `\\macro' being typed or
plain prose.  Elsewhere it always completes."
  (interactive)
  (cond
   ((not (my/cdlatex-active-p)) (corfu-complete))
   ((my/cdlatex-abbrev-p) (corfu-quit) (cdlatex-tab))
   ((looking-back "\\\\[A-Za-z@]*" (line-beginning-position)) (corfu-complete))
   ((or (cdlatex--texmathp) (looking-at-p "[]})$]")) (corfu-quit) (cdlatex-tab))
   (t (corfu-complete))))

(with-eval-after-load 'corfu
  (define-key corfu-map (kbd "TAB") #'my/corfu-tab)
  (define-key corfu-map (kbd "<tab>") #'my/corfu-tab))

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
