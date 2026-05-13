;;; my-latex-cdlatex.el --- CDLaTeX setup -*- lexical-binding: t; -*-

(require 'use-package)
(require 'my-latex)

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

Adds ENV template to `cdlatex-env-alist` and ABBR to
`cdlatex-command-alist`.

AUTOLABEL inserts an \"AUTOLABEL\" line.  OPTARG adds an optional
argument placeholder like [ ? ]."
    (let ((template (concat "\\begin{" env "}"
                            (when optarg "[?]")
                            "\n"
                            (when autolabel "AUTOLABEL\n")
                            (if optarg "\n" "?\n")
                            "\\end{" env "}\n")))
      (add-to-list 'cdlatex-env-alist (list env template nil) t)
      (add-to-list 'cdlatex-command-alist
                   (list abbr
                         (format "Insert %s env" env)
                         ""
                         #'cdlatex-environment
                         (list env)
                         t
                         nil)
                   t)))

  ;; Theorem environments
  (my/cdlatex-add-env "thm" "theorem" nil t)
  (my/cdlatex-add-env "lem" "lemma" nil t)
  (my/cdlatex-add-env "cor" "corollary")
  (my/cdlatex-add-env "def" "definition" nil t)
  (my/cdlatex-add-env "ex" "example")
  (my/cdlatex-add-env "rem" "remark" nil t)

  ;; Proof
  (my/cdlatex-add-env "prf" "proof")

  ;; Math
  (my/cdlatex-add-env "al" "align")
  (my/cdlatex-add-env "ga" "gather")

  ;; tcolorbox-style environments
  (my/cdlatex-add-env "idea" "idea")
  (my/cdlatex-add-env "pit" "pitfall")
  (my/cdlatex-add-env "int" "intuition")
  (my/cdlatex-add-env "ps" "proofsketch")

  (with-eval-after-load 'evil
    (add-hook 'LaTeX-mode-hook
              (lambda ()
                (evil-local-set-key 'insert (kbd "TAB") #'my/latex-tab)
                (evil-local-set-key 'insert (kbd "<tab>") #'my/latex-tab)))))

(provide 'my-latex-cdlatex)

;;; my-latex-cdlatex.el ends here
