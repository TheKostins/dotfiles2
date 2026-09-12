;;; early-init.el --- -*- lexical-binding: t; -*-

;; Defer GC and the file-name-handler-alist during startup.
;; file-name-handler-alist is consulted on every file-open; emptying it
;; for startup shaves real time off package loading.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 32 1024 1024)
                  gc-cons-percentage 0.1
                  file-name-handler-alist my/file-name-handler-alist)))

;; Frame / UI — set before the first frame is drawn.
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(width . 160)  default-frame-alist)
(push '(height . 40)  default-frame-alist)
(setq frame-resize-pixelwise t
      inhibit-startup-screen t
      initial-scratch-message nil
      native-comp-async-report-warnings-errors nil)

;; Load a module's .el when it's newer than its .elc. Without this, `require'
;; silently prefers a stale .elc and edits to the source do nothing.
(setq load-prefer-newer t)

;; We'll initialize package.el ourselves in init.el.
(setq package-enable-at-startup nil)
