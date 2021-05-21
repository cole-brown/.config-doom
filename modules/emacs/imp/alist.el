;;; emacs/imp/alist.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; A-list functions that are sane.
;;------------------------------------------------------------------------------

(defun iii:alist/general:valid/key (key)
  "Returns non-nil if KEY is valid.

Caller should probably raise an error if they get a nil returned."
  (not (stringp key)))
;; (iii:alist/general:valid/key 'foo)
;; (iii:alist/general:valid/key :foo)
;; (iii:alist/general:valid/key "foo")


(defun iii:alist/general:get (key alist)
  "Get cdr of KEY's entry in ALIST."
  ;;---
  ;; Error Checking
  ;;---
  (if (iii:alist/general:valid/key key)
      (alist-get key alist)
    (error (concat "iii:alist/general:get: "
                   "String key '%s' won't work... "
                   "Use `iii:alist/string:get' for string keys.")
           key)))


(defmacro iii:alist/general:update (key value alist)
  "Set/overwrite an entry in the alist.

If VALUE is nil, it will be set as KEY's value. Use
`iii:alist/general:delete' if you want to remove it.

Returns ALIST."
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist/general"))
        (mmm:key   (make-symbol "alist/general:key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (unless (iii:alist/general:valid/key ,mmm:key)
         (error (concat "iii:alist/general:update: "
                        "String key '%s' won't work... "
                        "Use `iii:alist/string:update' for string keys.")
                ,mmm:key))
       (setf (alist-get ,mmm:key ,mmm:alist) ,value)
       ,mmm:alist)))


(defmacro iii:alist/general:delete (key alist &optional set-alist)
  "Removes KEY from ALIST.

Returns ALIST."
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist/general"))
        (mmm:key   (make-symbol "alist/general:key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (unless (iii:alist/general:valid/key ,mmm:key)
         (error (concat "iii:alist/general:update: "
                        "String key '%s' won't work... "
                        "Use `iii:alist/string:delete' "
                        "for string keys.")
                ,mmm:key))
       (setf (alist-get ,mmm:key ,mmm:alist nil 'remove) nil)
       (when ,set-alist
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))
;; (let ((alist '((foo . bar))))
;;   (iii:alist/general:delete "foo" alist)
;;   alist)


;;------------------------------------------------------------------------------
;; String Alists
;;------------------------------------------------------------------------------

(defun iii:alist/string:valid/key (key)
  "Returns non-nil if KEY is valid.

Caller should probably raise an error if they get a nil returned."
  (stringp key))
;; (iii:alist/string:valid/key 'foo)
;; (iii:alist/string:valid/key :foo)
;; (iii:alist/string:valid/key "foo")


(defun iii:alist/string:get (key alist &optional default)
  "Get cdr of KEY's entry in ALIST.

If KEY is not in the alist, nil or DEFAULT will be returned."
  (unless (iii:alist/string:valid/key key)
    (error (concat "iii:alist/string:get: "
                   "Only string keys allowed. "
                   "Use `iii:alist/general:get' for non-string keys.")))
  (alist-get key alist default nil #'string=))


(defmacro iii:alist/string:update (key value alist &optional set-alist)
  "Set/overwrite an entry in the alist.

If VALUE is nil, it will be set as KEY's value. Use `iii:alist/string:delete' if
you want to remove it.

Returns ALIST."
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist/string"))
        (mmm:key   (make-symbol "alist/string:key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (unless (iii:alist/string:valid/key ,mmm:key)
         (error (concat "iii:alist/string:update: "
                        "Only string keys allowed. "
                        "Use `iii:alist/general:update' for non-string key %S.")
                ,mmm:key))

       (setf (alist-get ,mmm:key ,mmm:alist nil nil #'string=) ,value)
       (when ,set-alist
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))
;; (let ((alist '(("foo" . bar))))
;;   (iii:alist/string:update "foo" 'baz alist))


(defmacro iii:alist/string:delete (key alist &optional set-alist)
  "Removes KEY from ALIST.

Returns ALIST."
  ;; (declare (indent defun))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist/string"))
        (mmm:key   (make-symbol "alist/string:key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (unless (iii:alist/string:valid/key ,mmm:key)
         (error (concat "iii:alist/string:update: "
                        "Only string keys allowed. "
                        "Use `iii:alist/general:update' for non-string key %S.")
                ,mmm:key))

       (setf (alist-get ,mmm:key ,mmm:alist nil 'remove #'string=) nil)
       (when ,set-alist
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))
;; (let ((alist '(("foo" . bar))))
;;   (iii:alist/string:delete "foo" alist)
;;   alist)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
