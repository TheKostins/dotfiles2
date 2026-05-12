;;; my-pdf.el --- PDF viewing setup -*- lexical-binding: t; -*-

(require 'use-package)

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-page)
  ;; Enable midnight mode for a Gruvbox-like dark PDF background
  (setq pdf-view-midnight-colors '("#ebdbb2" . "#282828"))
  (add-hook 'pdf-view-mode-hook #'pdf-view-midnight-minor-mode)
  ;; More natural scrolling
  (add-hook 'pdf-view-mode-hook #'pdf-view-fit-width-to-window))

(provide 'my-pdf)

;;; my-pdf.el ends here
