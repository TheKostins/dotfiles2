;;; my-glass.el --- macOS Liquid Glass frames -*- lexical-binding: t; -*-

;; Real Liquid Glass (NSGlassEffectView, macOS 26+) needs a patched binary:
;; emacs-plus@31 built with the `frame-transparency' community patch plus
;; `ns-glass-effect.patch' from https://github.com/larrasket/emacs-liquid-glass
;; (recipe lives in ~/.config/emacs-plus/build.yml).  The patch adds the
;; `ns-glass-*' and `ns-alpha-glyphs-alpha' frame parameters used below.
;;
;; Support is probed per frame, so this module does nothing in a terminal, on
;; Linux, or on a stock build.  With only `frame-transparency' applied it falls
;; back to a blurred translucent background.

;; Rendering notes that shape the code below:
;; - Legibility comes from the glass tint (`ns-glass-tint-opacity', the theme
;;   background mixed into the glass), not from `alpha-background'.  The glass
;;   view spans the titlebar, Emacs only paints below it, so any opacity Emacs
;;   draws itself shows up as a body darker than the titlebar.
;; - Child frames are created with `after-make-frame-functions' bound to nil,
;;   so nothing here goes into `default-frame-alist' (every corfu/eldoc-box
;;   popup would turn into glass with no hook to undo it).  Top-level frames
;;   are handled by `my/glass-apply'; the vertico posframe opts in through
;;   `vertico-posframe-parameters'.
;; - Emacs flattens SVGs rendered by librsvg onto a solid background, so
;;   dvisvgm LaTeX previews show up as opaque boxes no matter what
;;   `org-format-latex-options' says.  NSImage loads the same files with their
;;   alpha intact (`native-image' type, same size), hence the advice at the end.

(defvar my/glass-enabled t
  "Non-nil when top-level frames should be glass.  See `my/toggle-glass'.")

(defvar my/glass-material 'regular
  "Native glass material: `regular' or `clear'.")
(defvar my/glass-tint-opacity 0.5
  "How much theme background is mixed into the glass: the opacity knob.
Near 0 is clear glass, 1 nearly hides the wallpaper.  Change it live with
`my/glass-set-opacity'.")
(defvar my/glass-popup-tint-opacity 0.4
  "Like `my/glass-tint-opacity' for the vertico posframe.
Lower, because its glass already blurs the buffer text behind it into a flat
backdrop; much higher and the popup turns into a plain dark panel.")
(defvar my/glass-alpha-background 0.01
  "Alpha of the default background Emacs paints over the glass.
Keep it near 0, see the rendering notes above.")
(defvar my/glass-glyphs-alpha 0.5
  "Alpha of non-default face backgrounds (hl-line, region, ...) on glass.")
(defvar my/glass-saturation 1.9
  "Saturation multiplier of the overlay shown on unfocused frames.")
(defvar my/glass-inactive-opacity 0.7
  "Opacity of the theme-background overlay shown on unfocused frames.
macOS drops the tint of unfocused glass, which makes the frame jump to a much
lighter grey; this overlay stands in for the tint.  Measured background
brightness: focused 37, unfocused 72 without the overlay, 48 with 0.7.")
(defvar my/glass-popup-inactive-opacity 0.05
  "Like `my/glass-inactive-opacity' for the vertico posframe.
A child frame never becomes the key window, so this overlay is always on.")
(defvar my/glass-corner-radius 2
  "Corner radius of the glass view.")

(defvar my/glass-fallback-alpha-background 0.70
  "Background alpha on builds with `frame-transparency' but no native glass.")
(defvar my/glass-fallback-blur 30
  "Blur radius on builds with `frame-transparency' but no native glass.")

(defun my/glass--native-p (frame)
  "Non-nil when FRAME's Emacs build has the `ns-glass-*' parameters."
  (and (eq (framep frame) 'ns)
       (assq 'ns-glass-material (frame-parameters frame))))

(defun my/glass--surface-parameters (frame tint inactive)
  "Return the parameters that make FRAME glass, or nil.
TINT is the tint opacity, INACTIVE the opacity of the unfocused overlay.
When `my/glass-enabled' is nil they make it opaque instead."
  (let ((native (my/glass--native-p frame)))
    (when (or native (assq 'ns-background-blur (frame-parameters frame)))
      (append
       '((ns-alpha-elements . (ns-alpha-all)))
       (cond
        ((not my/glass-enabled)
         '((alpha-background . 1.0) (ns-background-blur . 0)))
        (native
         `((alpha-background . ,my/glass-alpha-background)
           (ns-background-blur . 0)))
        (t
         `((alpha-background . ,my/glass-fallback-alpha-background)
           (ns-background-blur . ,my/glass-fallback-blur))))
       (when native
         (if my/glass-enabled
             `((ns-alpha-glyphs-alpha . ,(max my/glass-alpha-background
                                              my/glass-glyphs-alpha))
               (ns-glass-material . ,my/glass-material)
               (ns-glass-tint-opacity . ,tint)
               (ns-glass-saturation . ,my/glass-saturation)
               (ns-glass-inactive-opacity . ,inactive)
               (ns-glass-corner-radius . ,my/glass-corner-radius))
           '((ns-alpha-glyphs-alpha . nil)
             (ns-glass-material . nil))))))))

(defun my/glass-frame-parameters (frame)
  "Return the glass (or opaque) parameters for top-level FRAME, or nil."
  (when-let* ((surface (my/glass--surface-parameters
                        frame my/glass-tint-opacity
                        my/glass-inactive-opacity)))
    (append
     `((ns-transparent-titlebar . t)
       (ns-appearance . ,(if (eq (frame-parameter frame 'background-mode) 'light)
                             'light
                           'dark)))
     surface)))

(defvar vertico-posframe-parameters)

(defun my/glass-apply (&optional frame)
  "Apply the current glass state to FRAME if it is a top-level macOS frame."
  (let ((frame (or frame (selected-frame))))
    (when (and (eq (framep frame) 'ns)
               (not (frame-parent frame)))
      (modify-frame-parameters frame (my/glass-frame-parameters frame))
      ;; posframe recreates its frame when these change, so toggling and
      ;; `my/glass-set-opacity' reach the minibuffer popup too.
      (when (boundp 'vertico-posframe-parameters)
        (setq vertico-posframe-parameters
              (and my/glass-enabled
                   (my/glass--surface-parameters
                    frame my/glass-popup-tint-opacity
                    my/glass-popup-inactive-opacity)))))))

(defun my/glass-refresh ()
  "Re-apply the glass state to every frame."
  (mapc #'my/glass-apply (frame-list)))

(defun my/toggle-glass ()
  "Toggle the glass effect on every top-level frame."
  (interactive)
  (setq my/glass-enabled (not my/glass-enabled))
  (my/glass-refresh)
  (message "Glass %s" (if my/glass-enabled "on" "off")))

(defun my/glass-set-opacity (tint)
  "Set the glass tint opacity to TINT (0.0-1.0) on all frames."
  (interactive
   (list (read-number "Glass tint opacity (0.0-1.0): " my/glass-tint-opacity)))
  (setq my/glass-tint-opacity (max 0.0 (min 1.0 tint))
        my/glass-enabled t)
  (my/glass-refresh)
  (message "Glass tint opacity %.2f" my/glass-tint-opacity))

(global-set-key (kbd "C-c t g") #'my/toggle-glass)
(global-set-key (kbd "C-c t o") #'my/glass-set-opacity)

(my/glass-refresh)
(add-hook 'after-make-frame-functions #'my/glass-apply)
(with-eval-after-load 'vertico-posframe (my/glass-refresh))

(defun my/glass--native-svg-preview (fn beg end image &optional imagetype)
  "Around advice for `org--make-preview-overlay' (FN BEG END IMAGE IMAGETYPE).
Show an SVG preview through NSImage, which keeps its alpha, and paint the
default background behind it: fragments carry `org-block', whose background
would otherwise show as a box around the transparent image."
  (if (not (and my/glass-enabled
                (equal imagetype "svg")
                (my/glass--native-p (selected-frame))))
      (funcall fn beg end image imagetype)
    (prog1 (funcall fn beg end image "native-image")
      (dolist (ov (overlays-in beg end))
        (when (eq (overlay-get ov 'org-overlay-type) 'org-latex-overlay)
          (overlay-put ov 'face 'default))))))

;; Native LaTeX highlighting puts `org-block' on the whole regexp match, which
;; for $...$ includes the character before and after the fragment -- a space, a
;; comma, or the newline, and `org-block' extends a newline to the window edge.
;; Nearly invisible on an opaque frame, but non-default backgrounds are painted
;; at `my/glass-glyphs-alpha' on glass, so it shows as patches around previews.
(defvar my/glass--in-latex-fragment nil
  "Non-nil while `org-do-latex-and-related' is fontifying.")

(defun my/glass--mark-latex-fragment (fn &rest args)
  "Around advice for `org-do-latex-and-related' (FN ARGS)."
  (let ((my/glass--in-latex-fragment t))
    (apply fn args)))

(defun my/glass--strip-block-face (_lang start end)
  "After advice for `org-src-font-lock-fontify-block' (START END).
Drop `org-block' from a LaTeX fragment; real source blocks keep it."
  (when (and my/glass--in-latex-fragment
             my/glass-enabled
             (my/glass--native-p (selected-frame)))
    (let ((pos start))
      (while (< pos end)
        (let ((next (next-single-property-change pos 'face nil end))
              (face (get-text-property pos 'face)))
          (cond ((eq face 'org-block)
                 (remove-text-properties pos next '(face nil)))
                ((and (listp face) (memq 'org-block face))
                 (put-text-property pos next 'face (remq 'org-block face))))
          (setq pos next))))))

(with-eval-after-load 'org
  (advice-add 'org--make-preview-overlay :around
              #'my/glass--native-svg-preview)
  (advice-add 'org-do-latex-and-related :around
              #'my/glass--mark-latex-fragment))
(with-eval-after-load 'org-src
  (advice-add 'org-src-font-lock-fontify-block :after
              #'my/glass--strip-block-face))

(provide 'my-glass)

;;; my-glass.el ends here
