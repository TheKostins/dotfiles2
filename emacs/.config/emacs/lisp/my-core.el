;;; my-core.el --- Core editor defaults -*- lexical-binding: t; -*-

(setq debug-on-error t)
(setq frame-resize-pixelwise t)

(setq my/font "Pixel Code")

;; Font setup
(set-face-attribute 'default nil
                    :font my/font
                    :height 150
                    :weight 'regular)
(set-face-attribute 'fixed-pitch nil :font my/font :height 150)
(set-face-attribute 'variable-pitch nil :font my/font :height 150)

(add-hook 'prog-mode-hook
          (lambda ()
            (setq-local display-line-numbers 'relative)
            (line-number-mode t)
            (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
            (set-face-attribute 'font-lock-keyword-face nil :weight 'bold)))

(provide 'my-core)

;;; my-core.el ends here
