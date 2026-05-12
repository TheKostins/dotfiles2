;;; my-core.el --- Core editor defaults -*- lexical-binding: t; -*-

(setq debug-on-error t)
(setq frame-resize-pixelwise t)

(defvar my/font "Pixel Code")

(defun my/font-available-p (font)
  "Return non-nil when FONT is available."
  (find-font (font-spec :name font)))

(defun my/apply-font (&optional frame)
  "Apply `my/font' to FRAME when running graphically."
  (when (and (display-graphic-p frame)
             (my/font-available-p my/font))
    (with-selected-frame (or frame (selected-frame))
      (set-face-attribute 'default nil
                          :font my/font
                          :height 150
                          :weight 'regular)
      (set-face-attribute 'fixed-pitch nil :font my/font :height 150)
      (set-face-attribute 'variable-pitch nil :font my/font :height 150))))

(my/apply-font)
(add-hook 'after-make-frame-functions #'my/apply-font)

(set-face-attribute 'font-lock-comment-face nil :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil :weight 'bold)

(add-hook 'prog-mode-hook
          (lambda ()
            (setq-local display-line-numbers 'relative)
            (display-line-numbers-mode 1)))

(provide 'my-core)

;;; my-core.el ends here
