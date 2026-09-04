;;; my-ui.el --- Theme, paths, and UI integration -*- lexical-binding: t; -*-

(require 'use-package)

(use-package gruvbox-theme
  :init
  (load-theme 'gruvbox-dark-medium t)
  :config
  ;; The upstream `gruvbox-theme' package predates Emacs 29's tree-sitter
  ;; font-lock faces (used by rust-ts-mode, c-ts-mode, etc.), so anything
  ;; mapped only to those faces renders unstyled.
  ;;
  ;; Rather than port nvim's @-capture mapping verbatim, the palette below
  ;; follows one rule: *punctuation recedes, semantic categories get their
  ;; own hue*. Upstream paints every bracket, comma and operator in
  ;; `#fe8019' -- the highest-chroma color in gruvbox -- so syntax noise
  ;; outshouts identifiers. Here punctuation drops to the gray ramp and the
  ;; saturated hues are spent only on things worth scanning for.
  ;;
  ;;   red     keywords            green   strings
  ;;   yellow  functions           orange  builtins + string escapes
  ;;   aqua    types + preproc     purple  constants + numbers
  ;;   blue    properties          gray    comments + punctuation
  ;;   fg      variables (plain)
  ;;
  ;; Requires `treesit-font-lock-level' 4 (set in my-core.el) for the
  ;; -call/-use faces to be applied at all.
  (custom-theme-set-faces
   'gruvbox-dark-medium

   ;; --- Punctuation: structural, not semantic. Keep it quiet. ----------
   '(font-lock-bracket-face           ((t (:foreground "#a89984"))))
   '(font-lock-delimiter-face         ((t (:foreground "#928374"))))
   '(font-lock-misc-punctuation-face  ((t (:foreground "#928374"))))
   '(font-lock-punctuation-face       ((t (:foreground "#928374"))))
   ;; Operators carry a little more meaning than commas, so they sit one
   ;; step brighter -- but still on the gray ramp, not on orange.
   '(font-lock-operator-face          ((t (:foreground "#a89984"))))

   ;; --- Functions: one hue for declaration and call. -------------------
   ;; Upstream splits these (yellow declaration, green call), which both
   ;; renames the same entity mid-buffer and collides calls with strings.
   ;; Weight, not hue, marks the definition site.
   '(font-lock-function-name-face     ((t (:foreground "#fabd2f" :weight bold))))
   '(font-lock-function-call-face     ((t (:foreground "#fabd2f"))))

   ;; --- Types: pulled off purple, which was shared with numbers. -------
   '(font-lock-type-face              ((t (:foreground "#8ec07c"))))
   ;; Attributes / #include / #[derive] are meta-level: same family as
   ;; types, dimmed so they don't compete with the code they annotate.
   '(font-lock-preprocessor-face      ((t (:foreground "#689d6a"))))

   ;; --- Constants keep purple; a number *is* a constant, so the two
   ;; sharing a hue costs nothing now that types have moved out.
   '(font-lock-constant-face          ((t (:foreground "#d3869b"))))
   '(font-lock-number-face            ((t (:foreground "#d3869b"))))

   ;; --- Data: variables stay at the default foreground, declaration and
   ;; use alike. Variables are the single most common identifier on screen,
   ;; so coloring them spends the palette's loudest resource on its least
   ;; discriminating category -- plain text is the signal that there is
   ;; nothing special here. Both faces are set explicitly rather than left
   ;; unspecified, since the theme itself paints -name-face blue.
   '(font-lock-variable-name-face     ((t (:foreground "#ebdbb2"))))
   '(font-lock-variable-use-face      ((t (:foreground "#ebdbb2"))))
   ;; That frees blue to mean exactly one thing: a field access. `cfg.port'
   ;; now reads as plain-then-blue, so the property half stands out from
   ;; the variable it hangs off.
   '(font-lock-property-name-face     ((t (:foreground "#83a598"))))
   '(font-lock-property-use-face      ((t (:foreground "#83a598"))))

   ;; --- Strings: escapes and regexps stay hot against the green so they
   ;; stand out *inside* a literal. This is where orange earns its keep.
   '(font-lock-escape-face            ((t (:foreground "#fe8019"))))
   '(font-lock-regexp-face            ((t (:foreground "#fe8019"))))

   ;; --- Comments lifted from #7c6f64 (~3.0:1 on #282828, at the WCAG
   ;; floor) to #928374 (~4.3:1) so they read without a squint.
   '(font-lock-comment-face           ((t (:foreground "#928374"))))
   '(font-lock-doc-face               ((t (:inherit font-lock-comment-face)))))

  ;; --- The LSP layer -------------------------------------------------
  ;; Everything above is font-lock (tree-sitter). Eglot repaints on top of
  ;; it: `eglot--maybe-activate-editing-mode' turns on both
  ;; `eglot-semantic-tokens-mode' and `eglot-inlay-hints-mode'
  ;; unconditionally, and semantic tokens are installed with
  ;; `font-lock-add-keywords ... 'append', so the server's opinion lands
  ;; last. Faces live here rather than in my-eglot.el because
  ;; `custom-theme-set-faces' has to target the theme.
  ;;
  ;; Each `eglot-semantic-X' inherits a font-lock face (see
  ;; `eglot--semtok-types'), so the palette above mostly carries over for
  ;; free. Only the mappings that actively fight it are corrected below.
  (custom-theme-set-faces
   'gruvbox-dark-medium

   ;; Upstream maps operator -> `font-lock-function-name-face', so every
   ;; `+', `->' and `::' would come back yellow-bold from the server and
   ;; undo the punctuation rule in precisely the LSP buffers where it
   ;; matters most. Same story for `modifier' (public/const are keywords,
   ;; not functions) and `namespace' (mapped to keyword red, which makes
   ;; `std::' shout as loud as `if'; a namespace is a type-like container).
   '(eglot-semantic-operator   ((t (:inherit font-lock-operator-face))))
   '(eglot-semantic-modifier   ((t (:inherit font-lock-keyword-face))))
   '(eglot-semantic-namespace  ((t (:inherit font-lock-type-face))))
   ;; Macros arrive as preprocessor (now deliberately dimmed for
   ;; attributes). But `println!' is a call, not an annotation -- give it
   ;; the builtin orange so invocations stay legible.
   '(eglot-semantic-macro      ((t (:inherit font-lock-builtin-face))))
   ;; Upstream sends regexp to string green; match the font-lock choice.
   '(eglot-semantic-regexp     ((t (:inherit font-lock-regexp-face))))
   '(eglot-semantic-number     ((t (:inherit font-lock-number-face))))
   ;; Modifier faces are applied with `add-face-text-property', which
   ;; PREPENDS -- and eglot adds the token type first, modifiers after, so
   ;; a modifier ends up ahead of the type in the face list and wins every
   ;; attribute they both set. A variable declaration arrives as
   ;;   (eglot-semantic-declaration eglot-semantic-variable ...)
   ;; and upstream maps `declaration' to `font-lock-function-name-face',
   ;; so every declared variable came out yellow. The same hijack applies
   ;; across the board: readonly would paint purple, static red,
   ;; defaultLibrary orange, modification yellow -- each overriding the
   ;; token type that actually says what the thing is.
   ;;
   ;; So: the token type owns the hue, modifiers own the orthogonal
   ;; channels (weight, slant, strike-through) and set no foreground.
   '(eglot-semantic-declaration   ((t (:weight bold))))
   '(eglot-semantic-definition    ((t (:weight bold))))
   '(eglot-semantic-deprecated    ((t (:strike-through t))))
   '(eglot-semantic-static        ((t (:slant italic))))
   '(eglot-semantic-abstract      ((t (:slant italic))))
   ;; No visual channel at all -- these say nothing worth a hue.
   '(eglot-semantic-readonly      ((t ())))
   '(eglot-semantic-async         ((t ())))
   '(eglot-semantic-modification  ((t ())))
   '(eglot-semantic-documentation ((t ())))
   '(eglot-semantic-defaultLibrary ((t ())))
   ;; With bold now supplied by the declaration/definition modifier, the
   ;; type face must not also carry it, or every call site would go bold
   ;; too (LSP tags calls and definitions with the same `function' type).
   ;; Plain yellow here, bold only where the server says "defined here" --
   ;; which restores the decl/call split the tree-sitter faces make above.
   '(eglot-semantic-function      ((t (:foreground "#fabd2f"))))
   '(eglot-semantic-method        ((t (:foreground "#fabd2f"))))

   ;; Inlay hints are virtual text, not code. Upstream leans on `shadow'
   ;; (#7c6f64, ~3.0:1) to say so, which is the same washed-out floor the
   ;; comments were just lifted off -- and in Rust these are everywhere.
   ;; Separate them structurally with a background tint instead of by
   ;; dimness, and tie each to the hue of what it reports: aqua for types,
   ;; light4 for parameters -- the muted step on the same neutral ramp
   ;; variables now use. 0.8 -> 0.9 because 0.8 is genuinely tiny.
   '(eglot-inlay-hint-face     ((t (:height 0.9 :background "#32302f" :foreground "#928374"))))
   '(eglot-type-hint-face      ((t (:inherit eglot-inlay-hint-face :foreground "#689d6a"))))
   '(eglot-parameter-hint-face ((t (:inherit eglot-inlay-hint-face :foreground "#a89984"))))

   ;; Symbol-at-point highlighting defaults to `:inherit bold' with no
   ;; background, which is close to invisible in a buffer that already
   ;; uses bold for definition sites.
   '(eglot-highlight-symbol-face      ((t (:background "#504945"))))
   '(eglot-diagnostic-tag-unnecessary-face ((t (:foreground "#7c6f64"))))
   '(eglot-diagnostic-tag-deprecated-face  ((t (:foreground "#7c6f64" :strike-through t))))
   '(eglot-mode-line                  ((t (:foreground "#8ec07c" :weight bold))))
   '(eglot-code-action-indicator-face ((t (:foreground "#fabd2f" :weight bold))))

   ;; Flymake is eglot's diagnostics backend. Its wave underlines default
   ;; to "Red1"/"deep sky blue"/"yellow green" -- all off-palette, and a
   ;; blue warning is actively confusing here, where blue means variable.
   '(flymake-error   ((t (:underline (:style wave :color "#fb4933")))))
   '(flymake-warning ((t (:underline (:style wave :color "#fabd2f")))))
   '(flymake-note    ((t (:underline (:style wave :color "#83a598")))))

   ;; sideline-flymake renders those same diagnostics inline at end of
   ;; line. Notes inherit `success' (bright green bold), which makes an
   ;; informational hint shout as loudly as an error; rank them properly.
   '(sideline-flymake-error   ((t (:foreground "#fb4933"))))
   '(sideline-flymake-warning ((t (:foreground "#fabd2f"))))
   '(sideline-flymake-note    ((t (:foreground "#928374"))))
   '(sideline-default         ((t (:foreground "#fabd2f"))))   ; was literal "yellow"
   '(sideline-backend         ((t (:foreground "#7c6f64"))))   ; was off-palette "#9B9B9B"

   ;; eldoc-box draws a childframe; its border defaults to literal white,
   ;; which is a hard seam against gruvbox. Give the popup a slightly
   ;; lifted ground so it reads as a panel floating over the buffer.
   '(eldoc-box-border ((t (:background "#504945"))))
   '(eldoc-box-body   ((t (:background "#32302f" :foreground "#ebdbb2")))))
  (enable-theme 'gruvbox-dark-medium))

(use-package no-littering
  :config
  ;; Put autosaves, backups, etc. in ~/.emacs.d/var and ~/.emacs.d/etc
  (no-littering-theme-backups)
  (setq create-lockfiles nil)
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  (load custom-file 'noerror 'nomessage))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :ensure t
  :init
  (setq exec-path-from-shell-variables '("PATH" "MANPATH"))
  :config
  (exec-path-from-shell-initialize))

(provide 'my-ui)

;;; my-ui.el ends here
