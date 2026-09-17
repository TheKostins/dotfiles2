;;; my-russian-stem.el --- Snowball Russian stemmer -*- lexical-binding: t; -*-

;; A port of the Snowball Russian stemming algorithm
;; (https://snowballstem.org/algorithms/russian/stemmer.html).  It only ever
;; strips endings, so the stem of any inflected form is a prefix of that
;; form — which is what lets `my/russian-stem-regexp' turn a typed word into
;; a prefix regexp matching all its forms.

;;; Code:

(require 'cl-lib)

(defconst my/rus--vowels "аеиоуыэюя")

(defconst my/rus--perfective-gerund-1 '("в" "вши" "вшись")
  "Perfective gerund endings that must follow а or я.")
(defconst my/rus--perfective-gerund-2 '("ив" "ивши" "ившись" "ыв" "ывши" "ывшись"))
(defconst my/rus--adjective
  '("ее" "ие" "ые" "ое" "ими" "ыми" "ей" "ий" "ый" "ой" "ем" "им" "ым" "ом"
    "его" "ого" "ему" "ому" "их" "ых" "ую" "юю" "ая" "яя" "ою" "ею"))
(defconst my/rus--participle-1 '("ем" "нн" "вш" "ющ" "щ")
  "Participle endings that must follow а or я.")
(defconst my/rus--participle-2 '("ивш" "ывш" "ующ"))
(defconst my/rus--reflexive '("ся" "сь"))
(defconst my/rus--verb-1
  '("ла" "на" "ете" "йте" "ли" "й" "л" "ем" "н" "ло" "но" "ет" "ют" "ны" "ть"
    "ешь" "нно")
  "Verb endings that must follow а or я.")
(defconst my/rus--verb-2
  '("ила" "ыла" "ена" "ейте" "уйте" "ите" "или" "ыли" "ей" "уй" "ил" "ыл" "им"
    "ым" "ен" "ило" "ыло" "ено" "ят" "ует" "уют" "ит" "ыт" "ены" "ить" "ыть"
    "ишь" "ую" "ю"))
(defconst my/rus--noun
  '("а" "ев" "ов" "ие" "ье" "е" "иями" "ями" "ами" "еи" "ии" "и" "ией" "ей"
    "ой" "ий" "й" "иям" "ям" "ием" "ем" "ам" "ом" "о" "у" "ах" "иях" "ях" "ы"
    "ь" "ию" "ью" "ю" "ия" "ья" "я"))
(defconst my/rus--superlative '("ейш" "ейше"))
(defconst my/rus--derivational '("ост" "ость"))

(defsubst my/rus--vowel-p (c)
  (and c (cl-position c my/rus--vowels)))

(defun my/rus--regions (w)
  "Return (PV . P2) for W: the starts of the RV and R2 regions.
RV starts after the first vowel; R2 after the second vowel/non-vowel pair."
  (let ((len (length w)) (i 0) (pv nil) (p2 nil))
    (catch 'done
      (while (and (< i len) (not (my/rus--vowel-p (aref w i)))) (cl-incf i))
      (when (>= i len) (throw 'done nil))
      (setq pv (cl-incf i))
      (while (and (< i len) (my/rus--vowel-p (aref w i))) (cl-incf i))
      (when (>= i len) (throw 'done nil))
      (cl-incf i)
      (while (and (< i len) (not (my/rus--vowel-p (aref w i)))) (cl-incf i))
      (when (>= i len) (throw 'done nil))
      (cl-incf i)
      (while (and (< i len) (my/rus--vowel-p (aref w i))) (cl-incf i))
      (when (>= i len) (throw 'done nil))
      (setq p2 (cl-incf i)))
    (cons (or pv len) (or p2 len))))

(defun my/rus--longest-suffix (w limit endings)
  "Longest string in ENDINGS that ends W and starts at or after LIMIT."
  (let ((best nil) (len (length w)))
    (dolist (e endings)
      (when (and (string-suffix-p e w)
                 (>= (- len (length e)) limit)
                 (> (length e) (length best)))
        (setq best e)))
    best))

(defun my/rus--after-a-ya-p (w suffix limit)
  "Non-nil when SUFFIX of W is preceded by а or я inside LIMIT."
  (let ((i (- (length w) (length suffix) 1)))
    (and (>= i limit) (memq (aref w i) '(?а ?я)))))

(defun my/rus--chop (w suffix)
  (substring w 0 (- (length w) (length suffix))))

(defun my/russian-stem (word)
  "Return the Snowball stem of the Russian WORD."
  (let* ((w (string-replace "ё" "е" (downcase word)))
         (regions (my/rus--regions w))
         (pv (car regions))
         (p2 (cdr regions)))
    (cl-flet ((longest (endings) (my/rus--longest-suffix w pv endings)))
      ;; Step 1: perfective gerund, else reflexive + adjectival/verb/noun.
      (let* ((g (longest (append my/rus--perfective-gerund-1
                                my/rus--perfective-gerund-2)))
             (g-ok (and g (or (member g my/rus--perfective-gerund-2)
                              (my/rus--after-a-ya-p w g pv)))))
        (if g-ok
            (setq w (my/rus--chop w g))
          (let ((r (longest my/rus--reflexive)))
            (when r (setq w (my/rus--chop w r))))
          (let ((adj (longest my/rus--adjective)))
            (cond
             (adj
              (setq w (my/rus--chop w adj))
              (let* ((p (longest (append my/rus--participle-1
                                        my/rus--participle-2)))
                     (p-ok (and p (or (member p my/rus--participle-2)
                                      (my/rus--after-a-ya-p w p pv)))))
                (when p-ok (setq w (my/rus--chop w p)))))
             (t
              (let* ((v (longest (append my/rus--verb-1 my/rus--verb-2)))
                     (v-ok (and v (or (member v my/rus--verb-2)
                                      (my/rus--after-a-ya-p w v pv)))))
                (if v-ok
                    (setq w (my/rus--chop w v))
                  (let ((n (longest my/rus--noun)))
                    (when n (setq w (my/rus--chop w n)))))))))))
      ;; Step 2: trailing и.
      (when (longest '("и")) (setq w (my/rus--chop w "и")))
      ;; Step 3: derivational ending inside R2.
      (let ((d (my/rus--longest-suffix w (max pv p2) my/rus--derivational)))
        (when d (setq w (my/rus--chop w d))))
      ;; Step 4: superlative / undouble н / soft sign.
      (let ((s (longest (append my/rus--superlative '("н" "ь")))))
        (cond
         ((null s))
         ((member s my/rus--superlative)
          (setq w (my/rus--chop w s))
          (when (and (string-suffix-p "нн" w)
                     (>= (- (length w) 2) pv))
            (setq w (my/rus--chop w "н"))))
         ((equal s "н")
          (when (and (string-suffix-p "нн" w)
                     (>= (- (length w) 2) pv))
            (setq w (my/rus--chop w "н"))))
         ((equal s "ь")
          (setq w (my/rus--chop w "ь")))))
      w)))

(defun my/russian-stem-regexp (word)
  "Regexp matching any inflected form of the Russian WORD, or nil.
The stem must be at least three letters; ё and е are interchangeable."
  (let ((stem (my/russian-stem word)))
    (when (>= (length stem) 3)
      (concat "\\b"
              (replace-regexp-in-string "е" "[её]" (regexp-quote stem) t t)
              "[а-яё]*"))))

(provide 'my-russian-stem)
;;; my-russian-stem.el ends here
