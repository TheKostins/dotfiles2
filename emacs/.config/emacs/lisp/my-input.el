;;; my-input.el --- Cyrillic input matching the macOS keyboard -*- lexical-binding: t; -*-

;; Two separate problems, one shared layout definition:
;;
;; 1. Typing Russian without losing Emacs bindings: `C-\' toggles the
;;    `russian-mac' input method below while macOS stays on ABC, so every
;;    key still reaches Emacs as Latin.  Evil switches the input method off
;;    in normal state and back on in insert state by itself.
;;
;; 2. Bindings while macOS itself is switched to Russian: `reverse-im'
;;    translates the Cyrillic key events back, so `C-х' arrives as `C-[',
;;    `M-ф' as `M-a'.  It derives that translation from the same input
;;    method, so the layout is described in exactly one place.

(require 'quail)
(require 'use-package)

;; Emacs ships `russian-computer', which is the Windows/PC ЙЦУКЕН layout —
;; macOS exposes that one as the separate "Russian – PC" input source.  The
;; plain "Russian" source differs on nine keys: ё sits on \ rather than `,
;; ` carries ]/[, / and ? are literal, and the shifted number row reads
;; %:,.; where the PC layout has ;%:?*.  The rules below were dumped from
;; the macOS "Russian" layout itself (UCKeyTranslate), so they match it key
;; for key.

;;  §> 1! 2" 3№ 4% 5: 6, 7. 8; 9( 0) -_ =+  `] ~[  \ё |Ё
;;    Й  Ц  У  К  Е  Н  Г  Ш  Щ  З  Х  Ъ
;;     Ф  Ы  В  А  П  Р  О  Л  Д  Ж  Э
;;      Я  Ч  С  М  И  Т  Ь  Б  Ю  /?

(quail-define-package
 "russian-mac" "Russian" "RU" nil
 "ЙЦУКЕН Russian layout as shipped by macOS (the \"Russian\" input source,
not \"Russian – PC\", which is what `russian-computer' describes)."
 nil t t t t nil nil nil nil nil t)

(quail-define-rules
 ("1" ?1)
 ("2" ?2)
 ("3" ?3)
 ("4" ?4)
 ("5" ?5)
 ("6" ?6)
 ("7" ?7)
 ("8" ?8)
 ("9" ?9)
 ("0" ?0)
 ("-" ?-)
 ("=" ?=)
 ("`" ?\])
 ("\\" ?ё)
 ("q" ?й)
 ("w" ?ц)
 ("e" ?у)
 ("r" ?к)
 ("t" ?е)
 ("y" ?н)
 ("u" ?г)
 ("i" ?ш)
 ("o" ?щ)
 ("p" ?з)
 ("[" ?х)
 ("]" ?ъ)
 ("a" ?ф)
 ("s" ?ы)
 ("d" ?в)
 ("f" ?а)
 ("g" ?п)
 ("h" ?р)
 ("j" ?о)
 ("k" ?л)
 ("l" ?д)
 (";" ?ж)
 ("'" ?э)
 ("z" ?я)
 ("x" ?ч)
 ("c" ?с)
 ("v" ?м)
 ("b" ?и)
 ("n" ?т)
 ("m" ?ь)
 ("," ?б)
 ("." ?ю)
 ("/" ?/)
 ("!" ?!)
 ("@" ?\")
 ("#" ?№)
 ("$" ?%)
 ("%" ?:)
 ("^" ?,)
 ("&" ?.)
 ("*" ?\;)
 ("(" ?\()
 (")" ?\))
 ("_" ?_)
 ("+" ?+)
 ("~" ?\[)
 ("|" ?Ё)
 ("Q" ?Й)
 ("W" ?Ц)
 ("E" ?У)
 ("R" ?К)
 ("T" ?Е)
 ("Y" ?Н)
 ("U" ?Г)
 ("I" ?Ш)
 ("O" ?Щ)
 ("P" ?З)
 ("{" ?Х)
 ("}" ?Ъ)
 ("A" ?Ф)
 ("S" ?Ы)
 ("D" ?В)
 ("F" ?А)
 ("G" ?П)
 ("H" ?Р)
 ("J" ?О)
 ("K" ?Л)
 ("L" ?Д)
 (":" ?Ж)
 ("\"" ?Э)
 ("Z" ?Я)
 ("X" ?Ч)
 ("C" ?С)
 ("V" ?М)
 ("B" ?И)
 ("N" ?Т)
 ("M" ?Ь)
 ("<" ?Б)
 (">" ?Ю)
 ("?" ??)
 ;; ISO keyboards only; absent on ANSI, where the rules are simply unused.
 ("§" ?>)
 ("±" ?<))

(setq default-input-method "russian-mac")

;; Makes bindings survive macOS being switched to Russian.  Reads
;; `russian-mac' above, so there is nothing to keep in sync.
(use-package reverse-im
  :custom
  (reverse-im-input-methods '("russian-mac"))
  :config
  (reverse-im-mode 1))

(provide 'my-input)

;;; my-input.el ends here
