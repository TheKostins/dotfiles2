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

(defun my/spell--query (word)
  "Send WORD to the running ispell process; return the parsed answer."
  (setq ispell-filter nil)
  (ispell-send-string (concat "^" word "\n"))
  (while (progn (ispell-accept-output)
                (not (string= "" (car ispell-filter)))))
  (setq ispell-filter (cdr ispell-filter))
  (prog1 (and (consp ispell-filter)
              (ispell-parse-output (car ispell-filter)))
    (setq ispell-filter nil)))

(defvar my/spell--cache nil
  "Last (WORD . SUGGESTIONS); Corfu asks several times per popup.")

(defun my/spell-suggestions (word)
  "Return hunspell's corrections for WORD, or nil when it is spelled right.
Asks the ispell process Flyspell already keeps running, so there is no
process spawn and the dictionaries are loaded once.

With several dictionaries hunspell checks against all of them but only
suggests from the one that last accepted a word.  A known-good word in
WORD's script is sent first, so Russian typos get Russian corrections
even right after an English word, and vice versa."
  (if (equal word (car my/spell--cache))
      (cdr my/spell--cache)
    (require 'ispell)
    (ispell-set-spellchecker-params)
    (ispell-accept-buffer-local-defs)
    ;; Corfu computes candidates under `while-no-input'; an interrupted
    ;; round trip would leave a stale answer for the next query.
    (let* ((throw-on-input nil)
           (inhibit-quit t)
           (poss (progn
                   (ispell-send-string "%\n")
                   (my/spell--query
                    (if (string-match-p "[а-яёА-ЯЁ]" word) "слово" "the"))
                   (my/spell--query word)))
           (suggestions (and (consp poss) (nth 2 poss))))
      (setq my/spell--cache (cons word suggestions))
      suggestions)))

(defun my/spell-capf ()
  "CAPF offering spelling corrections for the word before point.
Returns nil for short or correctly spelled words so later CAPFs still run.
The table ignores the input string: corrections rarely share a prefix with
the misspelling, and completion styles must not filter them away."
  (when-let* ((bounds (bounds-of-thing-at-point 'word))
              ((= (cdr bounds) (point)))
              ((>= (- (cdr bounds) (car bounds)) 4))
              (word (buffer-substring-no-properties (car bounds) (cdr bounds)))
              (suggestions (ignore-errors (my/spell-suggestions word))))
    (list (car bounds) (cdr bounds)
          (lambda (_string _pred action)
            (pcase action
              ('metadata '(metadata (category . spelling)
                                    (display-sort-function . identity)
                                    (cycle-sort-function . identity)))
              ('t suggestions)
              (_ nil)))
          :exclusive 'no
          :annotation-function (lambda (_) " spell"))))

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
