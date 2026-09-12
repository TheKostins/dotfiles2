;;; my-org.el --- Zettelkasten notes: org-roam, LaTeX preview, images, Anki, review -*- lexical-binding: t; -*-

;; One `C-c n' prefix (from Evil normal state: `SPC c SPC n <key>') and one
;; vault at `my/notes-dir'.  Notes are org-roam nodes; a note is either text
;; with LaTeX or an image pasted from the iPad plus a caption — both are
;; plain nodes, so linking and search are identical.
;;
;; Search rides on what already exists: `C-x b' gets a hidden "Notes" source
;; (narrow with `n'), `org-roam-node-find' gets Consult live preview, and
;; `C-c n s' is `consult-ripgrep' over the vault.
;;
;; Review has two tiers: flashcards are org headings pushed to Anki with
;; `anki-editor' (reviewed on the iPad), whole notes are re-read on a
;; SCHEDULED timestamp that `my/roam-review' stretches on each rating.
;;
;; Themes are `#+filetags'.  `my/roam-theme-assemble' collects every note
;; carrying a tag into one org file via `org-transclusion', ready for PDF
;; export with the normal `C-c C-e l p'.

(require 'use-package)
(require 'cl-lib)

(declare-function no-littering-expand-var-file-name "no-littering")
(defvar tex--prettify-symbols-alist)

(defvar my/notes-dir (expand-file-name "~/Documents/notes/roam/")
  "Root of the org-roam vault.")
(defvar my/notes-image-dir (expand-file-name "images/" my/notes-dir)
  "Where pasted images land.  Links are written relative to the note.")
(defvar my/notes-review-tag "review"
  "Filetag marking notes that are on the periodic review schedule.")
(defvar my/notes-workflow-tags '("review" "hub" "lecture" "image")
  "Tags that describe workflow, not subject matter.  Never sent to Anki.")
(defvar my/anki-deck-root "Notes"
  "Anki parent deck; a note's first subject tag becomes the subdeck.")

;;;; org ---------------------------------------------------------------------

(defun my/org-prettify ()
  "Show TeX symbols as glyphs outside previews, as in LaTeX buffers."
  (require 'tex-mode)
  (setq-local prettify-symbols-alist
              (append tex--prettify-symbols-alist prettify-symbols-alist))
  (prettify-symbols-mode 1))

(defun my/org-tab ()
  "TAB in org insert state.
Expand a CDLaTeX abbreviation anywhere on the line, else `org-cycle'
\(which still handles TAB inside math fragments).  Org itself only
expands the first word of a line."
  (interactive)
  (if (my/cdlatex-abbrev-p)
      (cdlatex-tab)
    (org-cycle)))

(defun my/org-editing-setup ()
  "Per-buffer tweaks so CDLaTeX behaves as in LaTeX buffers."
  (face-remap-add-relative 'default :height my/notes-text-height)
  ;; Org's syntax table pairs <> for timestamps; electric-pair would turn
  ;; `lr<' into `lr<>' and leave the `>' behind after expansion.
  (setq-local electric-pair-inhibit-predicate
              (lambda (c)
                (or (eq c ?<) (electric-pair-default-inhibit c))))
  (with-eval-after-load 'evil
    (evil-local-set-key 'insert (kbd "TAB") #'my/org-tab)
    (evil-local-set-key 'insert (kbd "<tab>") #'my/org-tab)))

(use-package org
  :ensure nil
  :hook ((org-mode . org-cdlatex-mode)
         (org-mode . visual-line-mode)
         (org-mode . my/org-prettify)
         (org-mode . my/org-editing-setup))
  :config
  ;; LaTeX preview: dvisvgm renders SVGs that scale with the font and pick up
  ;; the theme foreground.  dvisvgm finds Ghostscript only through LIBGS.
  (unless (getenv "LIBGS")
    (let ((libgs "/opt/homebrew/lib/libgs.dylib"))
      (when (file-exists-p libgs) (setenv "LIBGS" libgs))))
  (setq org-preview-latex-default-process 'dvisvgm
        org-preview-latex-image-directory
        (no-littering-expand-var-file-name "org/ltximg/")
        org-startup-with-latex-preview t
        org-startup-with-inline-images t
        org-image-actual-width '(600)
        org-highlight-latex-and-related '(native latex script entities)
        ;; Entity overlays would render \alpha twice next to SVG previews.
        org-pretty-entities nil)
  ;; dvisvgm already applies :image-size-adjust 1.7; 1.25 keeps previews in
  ;; step with `my/notes-text-height' (previews ignore face remapping).
  (setq org-format-latex-options
        (thread-first org-format-latex-options
                      (plist-put :scale 1.25)
                      (plist-put :foreground 'default)
                      (plist-put :background "Transparent")))

  ;; Cyrillic in previews and PDF export: fontenc's last option is the
  ;; default encoding, so T2A must come after T1.
  (setq org-latex-default-packages-alist
        (mapcar (lambda (pkg)
                  (if (equal pkg '("T1" "fontenc" t ("pdflatex")))
                      '("T1,T2A" "fontenc" t ("pdflatex"))
                    pkg))
                org-latex-default-packages-alist))
  (setq org-latex-packages-alist
        '(("russian,english" "babel" t)
          ("" "amsthm" t))
        org-latex-compiler "pdflatex"
        org-latex-pdf-process
        '("latexmk -pdf -f -interaction=nonstopmode -output-directory=%o %f"))

  ;; Headings step down in size so structure reads at a glance.
  (set-face-attribute 'org-document-title nil :height 1.4 :weight 'bold)
  (set-face-attribute 'org-level-1 nil :height 1.25 :weight 'bold)
  (set-face-attribute 'org-level-2 nil :height 1.15 :weight 'semi-bold)
  (set-face-attribute 'org-level-3 nil :height 1.05)

  ;; Whole-note review lives on SCHEDULED timestamps; the agenda only looks
  ;; at notes tagged `my/notes-review-tag' (see `my/roam-files-with-tag').
  (setq org-agenda-custom-commands
        '(("n" "Notes to review" agenda ""
           ((org-agenda-span 'day)
            (org-agenda-overriding-header "Notes to review")
            (org-agenda-files (my/roam-files-with-tag my/notes-review-tag)))))))

;; Centre the note text in the window.
(use-package olivetti
  :hook (org-mode . olivetti-mode)
  :config
  (setq olivetti-body-width 90))

;; Prose in a proportional serif (pairs with the Computer Modern previews
;; and has full Cyrillic); code, tables, tags, timestamps and LaTeX source
;; stay in `my/font'.  Sans alternatives installed here: "IBM Plex Sans",
;; "Inter".
(defvar my/notes-font "IBM Plex Serif"
  "Proportional family for note prose.")
(defvar my/notes-text-height 1.15
  "Text height in note buffers relative to `my/font'.
Keep the :scale in `org-format-latex-options' in step so previews match.")

(defface my/notes-prose `((t :inherit variable-pitch :family ,my/notes-font))
  "Prose face for notes; `mixed-pitch' reads its family."
  :group 'org-faces)

(use-package mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-face 'my/notes-prose
        mixed-pitch-set-height nil
        ;; Evil already manages the cursor shape per state.
        mixed-pitch-variable-pitch-cursor nil)
  (dolist (face '(org-property-value org-drawer org-special-keyword
                  org-date org-tag org-hide))
    (add-to-list 'mixed-pitch-fixed-pitch-faces face)))

;; Toggle previews automatically as point enters/leaves a fragment.
(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode)
  :config
  (setq org-fragtog-preview-delay 0.2))

;;;; org-roam ----------------------------------------------------------------

(defvar my/roam-image-template
  '(("i" "image" plain "%?"
     :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                        "#+title: ${title}\n#+filetags: :image:\n\n")
     :unnarrowed t
     :immediate-finish t
     :finalize find-file))
  "Capture template for a note whose body is a pasted image plus caption.
Kept out of `org-roam-capture-templates' so it does not appear in the menu;
`my/roam-paste-image' uses it directly.")

(use-package org-roam
  :init
  (setq org-roam-directory my/notes-dir)
  :commands (org-roam-node-find org-roam-node-insert org-roam-buffer-toggle
             org-roam-capture org-roam-tag-add)
  :config
  (make-directory my/notes-image-dir t)
  (setq org-roam-file-exclude-regexp (list org-attach-id-dir "\\`theme-")
        org-roam-node-display-template
        (concat "${title:*} " (propertize "${tags:24}" 'face 'org-tag))
        org-roam-capture-templates
        '(("d" "concept" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags:\n\n")
           :unnarrowed t)
          ("t" "theme hub" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :hub:\n\n* Notes\n\n* Open questions\n")
           :unnarrowed t)
          ("l" "lecture" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :lecture:\n#+date: %<%Y-%m-%d>\n\n")
           :unnarrowed t)))
  ;; Backlinks in a side window on the right.
  (add-to-list 'display-buffer-alist
               '("\\*org-roam\\*"
                 (display-buffer-in-side-window)
                 (side . right) (slot . 0) (window-width . 0.33)
                 (window-parameters . ((no-delete-other-windows . t)))))
  (org-roam-db-autosync-mode 1))

;; Consult completion (live preview) for org-roam-node-find/insert and a
;; ripgrep search over the vault.  Its own open-buffers source is replaced
;; by the all-nodes source below.
(use-package consult-org-roam
  :after (consult org-roam)
  :init
  (setq consult-org-roam-buffer-enabled nil)
  :config
  (setq consult-org-roam-grep-func #'consult-ripgrep)
  (consult-org-roam-mode 1))

(defvar my/consult-source-roam-node
  `(:name     "Notes"
    :narrow   ?n
    :category org-roam-node
    :hidden   t
    :items    ,(lambda ()
                 (when (require 'org-roam nil t)
                   ;; (display . node) conses: consult hands the node, not
                   ;; the string, to :state and :action.
                   (org-roam-node-read--completions)))
    :state    ,(lambda ()
                 (require 'consult-org-roam)
                 (consult-org-roam--node-preview))
    :action   ,(lambda (node) (org-roam-node-visit node))
    :new      ,(lambda (title)
                 (org-roam-capture- :node (org-roam-node-create :title title)
                                    :keys "d"
                                    :props '(:finalize find-file))))
  "`consult-buffer' source for every org-roam node.
Hidden until narrowed: `C-x b n SPC' lists notes with tags, previews them,
and creates a note from unmatched input.")

(with-eval-after-load 'consult
  (add-to-list 'consult-buffer-sources 'my/consult-source-roam-node 'append))

;;;; Images from the iPad ----------------------------------------------------

;; `org-download-clipboard' uses pngpaste on macOS and links the file
;; relative to the note, so the vault stays portable.
(use-package org-download
  :after org
  :commands (org-download-clipboard org-download-screenshot)
  :config
  (setq org-download-method 'directory
        org-download-image-dir my/notes-image-dir
        org-download-heading-lvl nil
        org-download-timestamp "%Y%m%d-%H%M%S_"
        org-download-image-org-width 600
        org-download-screenshot-file
        (no-littering-expand-var-file-name "org/download-screenshot.png")
        org-download-annotate-function (lambda (_link) "")))

;;;; Flashcards → Anki --------------------------------------------------------

(use-package anki-editor
  :commands (anki-editor-mode anki-editor-push-notes anki-editor-push-note-at-point
             anki-editor-insert-note anki-editor-insert-default-note
             anki-editor-cloze-dwim)
  :config
  (setq anki-editor-latex-style 'mathjax
        anki-editor-org-tags-as-anki-tags t
        anki-editor-ignored-org-tags
        (append my/notes-workflow-tags anki-editor-ignored-org-tags)))

;;;; Theme assembly ----------------------------------------------------------

(use-package org-transclusion
  :after org
  :commands (org-transclusion-mode org-transclusion-add-all))

;; Graph view in the browser: M-x org-roam-ui-open.
(use-package org-roam-ui
  :after org-roam
  :commands (org-roam-ui-mode org-roam-ui-open)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;;;; Helpers -----------------------------------------------------------------

(declare-function org-roam-db-query "org-roam-db")
(declare-function org-roam-file-p "org-roam")
(declare-function org-roam-tag-add "org-roam-node")
(declare-function org-roam-tag-completions "org-roam-node")
(declare-function org-roam-capture- "org-roam-capture")
(declare-function org-roam-node-create "org-roam-node")
(declare-function org-roam-node-visit "org-roam-node")
(declare-function org-roam-node-read--completions "org-roam-node")
(declare-function org-collect-keywords "org")
(declare-function org-entry-get "org")
(declare-function org-entry-put "org")
(declare-function org-entry-get-with-inheritance "org")
(declare-function org-set-regexps-and-options "org")
(declare-function org-find-exact-headline-in-buffer "org")
(declare-function org-schedule "org")
(declare-function org-back-to-heading "org")
(declare-function org-up-heading-safe "org")
(declare-function org-toggle-tag "org")
(declare-function evil-local-set-key "evil-core")
(declare-function cdlatex-tab "cdlatex")
(declare-function consult-org-roam-search "consult-org-roam")
(declare-function anki-editor-insert-note "anki-editor")
(declare-function anki-editor-insert-default-note "anki-editor")
(declare-function anki-editor-push-notes "anki-editor")
(defvar consult-ripgrep-args)
(defvar anki-editor-api-host)
(defvar anki-editor-api-port)

(defun my/roam-files-with-tag (tag)
  "Return the files of all org-roam nodes tagged TAG."
  (require 'org-roam)
  (mapcar #'car
          (org-roam-db-query
           [:select :distinct [nodes:file]
            :from tags
            :inner-join nodes :on (= tags:node-id nodes:id)
            :where (= tags:tag $s1)]
           tag)))

(defun my/roam-filetags ()
  "Return the `#+filetags' of the current buffer as a list of strings."
  (let ((line (cadr (assoc "FILETAGS" (org-collect-keywords '("FILETAGS"))))))
    (when line
      (split-string line ":" t "[ \t]+"))))

(defun my/roam-in-note-p ()
  "Non-nil when the current buffer is a note inside the vault."
  (and (derived-mode-p 'org-mode)
       (require 'org-roam nil t)
       (org-roam-file-p)))

;;; Search

(defun my/roam-search ()
  "Ripgrep over the vault with live preview, skipping assembled theme files."
  (interactive)
  (require 'consult-org-roam)
  (let ((consult-ripgrep-args
         (concat consult-ripgrep-args " --glob !theme-*.org")))
    (consult-org-roam-search)))

;;; Images

(defun my/roam-paste-image (&optional title)
  "Paste the clipboard image into the note at point.
Outside a note, ask for TITLE, create an image note and paste into it.
Copy on the iPad, paste here: Universal Clipboard carries the image."
  (interactive
   (list (unless (my/roam-in-note-p)
           (read-string "Image note title: "))))
  (unless (executable-find "pngpaste")
    (user-error "pngpaste is missing: brew install pngpaste"))
  (require 'org-roam)
  (require 'org-download)
  (when title
    (org-roam-capture- :node (org-roam-node-create :title title)
                       :templates my/roam-image-template)
    (goto-char (point-max)))
  (org-download-clipboard))

;;; Anki

(defun my/anki-deck-for-buffer ()
  "Deck for cards in this note: inherited ANKI_DECK, else root::first tag."
  (or (org-entry-get-with-inheritance "ANKI_DECK")
      (let ((subject (seq-find (lambda (tag)
                                 (not (member tag my/notes-workflow-tags)))
                               (my/roam-filetags))))
        (if subject
            (concat my/anki-deck-root "::" subject)
          my/anki-deck-root))))

(defun my/anki-ensure-deck ()
  "Make sure the note carries a file-level ANKI_DECK property; return it."
  (or (org-entry-get-with-inheritance "ANKI_DECK")
      (let ((deck (my/anki-deck-for-buffer)))
        (save-excursion
          (goto-char (point-min))
          (if (re-search-forward "^#\\+\\(filetags\\|title\\):.*$" nil t)
              (insert "\n#+property: ANKI_DECK " deck)
            (insert "#+property: ANKI_DECK " deck "\n")))
        (org-set-regexps-and-options)
        deck)))

(defmacro my/with-anki (&rest body)
  "Run BODY, turning an unreachable AnkiConnect into a short `user-error'."
  (declare (indent 0))
  `(condition-case err
       (progn ,@body)
     (error
      (if (string-match-p "AnkiConnect\\|cURL\\|curl" (error-message-string err))
          (user-error "Anki is not running (AnkiConnect unreachable at %s:%s)"
                      anki-editor-api-host anki-editor-api-port)
        (signal (car err) (cdr err))))))

(defun my/anki-card (&optional arg)
  "Insert a flashcard skeleton after the current subtree.
Without ARG it is a Basic card (Front/Back); with ARG choose the note type,
e.g. Cloze.  The deck is derived from the note's first subject tag and the
card heading is tagged `noexport' so theme documents skip it."
  (interactive "P")
  (unless (my/roam-in-note-p)
    (user-error "Not in a note"))
  (require 'anki-editor)
  (let ((deck (my/anki-ensure-deck)))
    (my/with-anki
      (if arg
          (anki-editor-insert-note)
        (anki-editor-insert-default-note)))
    ;; Cards are review material, not prose: keep them out of theme
    ;; exports.  anki-editor ignores `noexport' when pushing tags.
    (save-excursion
      (org-back-to-heading t)
      (while (and (not (org-entry-get nil "ANKI_NOTE_TYPE"))
                  (org-up-heading-safe)))
      (when (org-entry-get nil "ANKI_NOTE_TYPE")
        (org-toggle-tag "noexport" 'on)))
    (message "Card in deck %s — fill it in, then C-c n a pushes it" deck)))

(defun my/anki-push ()
  "Push every new or changed card in this note to Anki."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "Not in an org buffer"))
  (require 'anki-editor)
  (my/with-anki (anki-editor-push-notes)))

;;; Whole-note review (tier 2)

(defun my/roam-review--heading ()
  "Position of the note's review heading, or nil."
  (org-find-exact-headline-in-buffer "Review"))

(defun my/roam-review--schedule (days)
  "Schedule the heading at point DAYS from today and remember the interval."
  (org-entry-put nil "REVIEW_INTERVAL" (number-to-string days))
  (org-schedule nil (format-time-string
                     "<%Y-%m-%d %a>"
                     (time-add (current-time) (days-to-time days)))))

(defun my/roam-review (&optional arg)
  "Put the note on the review schedule, or rate a review you just did.
First call: tag the note `review' and add a `noexport' Review heading
scheduled in 7 days (ARG asks for the number of days).  Later calls ask
how recall went: hard halves the interval, good doubles it, easy triples
it, and the next date is set."
  (interactive "P")
  (unless (my/roam-in-note-p)
    (user-error "Not in a note"))
  (let ((pos (my/roam-review--heading)))
    (save-excursion
      (if (not pos)
          (let ((days (if arg (read-number "First review in days: " 7) 7)))
            (goto-char (point-min))
            (org-roam-tag-add (list my/notes-review-tag))
            (goto-char (point-max))
            (unless (bolp) (insert "\n"))
            (insert "\n* Review :" my/notes-review-tag ":noexport:\n")
            (forward-line -1)
            (my/roam-review--schedule days)
            (message "Review scheduled in %d days" days))
        (goto-char pos)
        (let* ((current (string-to-number
                         (or (org-entry-get nil "REVIEW_INTERVAL") "7")))
               (rating (read-char-choice
                        (format "Recall after %dd: (h)ard (g)ood (e)asy "
                                current)
                        '(?h ?g ?e)))
               (next (pcase rating
                       (?h (max 1 (/ current 2)))
                       (?g (* 2 current))
                       (?e (* 3 current)))))
          (my/roam-review--schedule next)
          (message "Next review in %d days" next))))
    (save-buffer)))

(defun my/roam-review-agenda ()
  "Agenda of notes due for review (overdue ones included)."
  (interactive)
  (org-agenda nil "n"))

;;; Theme assembly

(defun my/roam--note-body (path)
  "Body of the note at PATH without its property drawer and keywords.
Headings are demoted one level so they sit under the theme heading."
  (with-temp-buffer
    (insert-file-contents path)
    (goto-char (point-min))
    (when (looking-at-p ":PROPERTIES:")
      (re-search-forward "^:END:\n" nil t))
    (while (and (not (eobp))
                (looking-at-p "^\\(#\\+\\|[ \t]*$\\)"))
      (forward-line 1))
    (replace-regexp-in-string
     "^\\*" "**"
     (string-trim (buffer-substring-no-properties (point) (point-max))))))

(defun my/roam-theme-assemble (tag &optional flatten)
  "Collect every note tagged TAG into `theme-TAG.org' and open it.
Each note becomes a section transcluded live from its source; export the
file with the usual `C-c C-e l p'.  With FLATTEN (prefix arg) copy the note
bodies instead, producing a standalone file."
  (interactive
   (list (completing-read "Theme tag: " (org-roam-tag-completions) nil t)
         current-prefix-arg))
  (require 'org-roam)
  (let ((rows (org-roam-db-query
               [:select [nodes:id nodes:title nodes:file]
                :from tags
                :inner-join nodes :on (= tags:node-id nodes:id)
                :where (and (= tags:tag $s1) (= nodes:level 0))
                :order-by nodes:title]
               tag))
        (file (expand-file-name (format "theme-%s.org" tag) my/notes-dir)))
    (unless rows
      (user-error "No notes tagged %s" tag))
    ;; Regenerating over an open copy would trigger a revert prompt.
    (when-let* ((buf (find-buffer-visiting file)))
      (with-current-buffer buf (set-buffer-modified-p nil))
      (kill-buffer buf))
    (with-temp-file file
      (insert (format "#+title: %s\n#+options: toc:nil\n\n" (capitalize tag)))
      (pcase-dolist (`(,id ,title ,path) rows)
        (insert (format "* %s\n" title))
        (if flatten
            (insert (my/roam--note-body path) "\n\n")
          (insert (format "#+transclude: [[id:%s]] :level 2 :exclude-elements \"keyword property-drawer\"\n\n"
                          id)))))
    (find-file file)
    (unless flatten
      (org-transclusion-mode 1))
    (message "%d notes under %s%s" (length rows) tag
             (if flatten "" " (transcluded; C-c C-e l p exports to PDF)"))))

;;;; Keys: one prefix, C-c n --------------------------------------------------

(defvar my/notes-map (make-sparse-keymap)
  "Notes commands under `C-c n'.")
(define-key global-map (kbd "C-c n") my/notes-map)

(define-key my/notes-map (kbd "f") #'org-roam-node-find)
(define-key my/notes-map (kbd "i") #'org-roam-node-insert)
(define-key my/notes-map (kbd "b") #'org-roam-buffer-toggle)
(define-key my/notes-map (kbd "s") #'my/roam-search)
(define-key my/notes-map (kbd "p") #'my/roam-paste-image)
(define-key my/notes-map (kbd "t") #'org-roam-tag-add)
(define-key my/notes-map (kbd "T") #'my/roam-theme-assemble)
(define-key my/notes-map (kbd "r") #'my/roam-review)
(define-key my/notes-map (kbd "R") #'my/roam-review-agenda)
(define-key my/notes-map (kbd "a") #'my/anki-push)
(define-key my/notes-map (kbd "A") #'my/anki-card)

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements "C-c n" "notes"))

(provide 'my-org)
;;; my-org.el ends here
