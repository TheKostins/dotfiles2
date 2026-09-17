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

(defvar my/glass-enabled t
  "Non-nil when top-level frames should be glass.  See `my/toggle-glass'.")

(defvar my/glass-material 'regular
  "Native glass material: `regular' or `clear'.")
(defvar my/glass-alpha-background 0.01
  "Alpha of the default background on glass; the glass view shows through it.")
(defvar my/glass-glyphs-alpha 0.24
  "Alpha of non-default face backgrounds (hl-line, region, ...) on glass.")
(defvar my/glass-tint-opacity 0.05
  "How strongly the glass is tinted with the theme background.")
(defvar my/glass-saturation 1.9
  "Saturation multiplier of the overlay shown on unfocused frames.")
(defvar my/glass-inactive-opacity 0.05
  "Opacity of the overlay shown on unfocused frames.")
(defvar my/glass-corner-radius 2
  "Corner radius of the glass view.")

(defvar my/glass-fallback-alpha-background 0.70
  "Background alpha on builds with `frame-transparency' but no native glass.")
(defvar my/glass-fallback-blur 30
  "Blur radius on builds with `frame-transparency' but no native glass.")

(defun my/glass-frame-parameters (frame)
  "Return the glass (or opaque) parameters FRAME's build supports, or nil."
  (let* ((known (frame-parameters frame))
         (native (assq 'ns-glass-material known))
         (blur (assq 'ns-background-blur known))
         (dark (not (eq (frame-parameter frame 'background-mode) 'light))))
    (when (or native blur)
      (append
       `((ns-transparent-titlebar . t)
         (ns-appearance . ,(if dark 'dark 'light))
         (ns-alpha-elements . (ns-alpha-all)))
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
               (ns-glass-tint-opacity . ,my/glass-tint-opacity)
               (ns-glass-saturation . ,my/glass-saturation)
               (ns-glass-inactive-opacity . ,my/glass-inactive-opacity)
               (ns-glass-corner-radius . ,my/glass-corner-radius))
           '((ns-alpha-glyphs-alpha . nil)
             (ns-glass-material . nil))))))))

;; Deliberately not in `default-frame-alist': child frames (vertico-posframe,
;; corfu, eldoc-box) inherit that alist and are created with
;; `after-make-frame-functions' bound to nil, so they would turn into
;; unreadable glass with no hook to undo it.  Applying per top-level frame
;; keeps popups opaque.
(defun my/glass-apply (&optional frame)
  "Apply the current glass state to FRAME if it is a top-level macOS frame."
  (let ((frame (or frame (selected-frame))))
    (when (and (eq (framep frame) 'ns)
               (not (frame-parent frame)))
      (modify-frame-parameters frame (my/glass-frame-parameters frame)))))

(defun my/toggle-glass ()
  "Toggle the glass effect on every top-level frame."
  (interactive)
  (setq my/glass-enabled (not my/glass-enabled))
  (mapc #'my/glass-apply (frame-list))
  (message "Glass %s" (if my/glass-enabled "on" "off")))

(global-set-key (kbd "C-c t g") #'my/toggle-glass)

(mapc #'my/glass-apply (frame-list))
(add-hook 'after-make-frame-functions #'my/glass-apply)

(provide 'my-glass)

;;; my-glass.el ends here
