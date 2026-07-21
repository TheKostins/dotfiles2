;;; my-core.el --- Core editor defaults -*- lexical-binding: t; -*-

(setq frame-resize-pixelwise t)
(setq sentence-end-double-space nil)

(delete-selection-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(winner-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(global-hl-line-mode 1)

(setq recentf-max-saved-items 200
      recentf-max-menu-items 25
      global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

(defvar my/font "IBM Plex Mono")

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
      (set-face-attribute 'variable-pitch nil :font "IBM Plex Sans" :height 150))))

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
