;;; input/keyboard/alist.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                         Better Alist Functions                         ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;               At least these all have 'alist' in the name...               ;;
;;                                 ──────────                                 ;;


;; Helper functions for alists that follow a convention for naming and stuff.
;; And will assist you in keeping you alist up-to-date, like it's a variable
;; or something.


;;------------------------------------------------------------------------------
;; A-list functions that are sane.
;;------------------------------------------------------------------------------

(defun int<keyboard>:alist:get/value (key alist)
  "Get cdr of KEY's entry in ALIST."
  (alist-get key alist))


(defun int<keyboard>:alist:get/pair (key alist)
  "Get full assoc/entry of KEY in ALIST."
  (assoc key alist))


(defmacro int<keyboard>:alist:update (key value alist &optional set-existing?)
  "Set/overwrite an entry in the alist.

If VALUE is nil, it will be set as KEY's value. Use
`int<keyboard>:alist:delete' if you want to remove it.

Returns ALIST."
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist:general"))
        (mmm:key   (make-symbol "alist:general/key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (when (stringp ,mmm:key)
         (int<keyboard>:output :error
                               "int<keyboard>:alist:update"
                               '("String key '%s' won't work... "
                                 "Use `int<keyboard>:alist/string:update' for string keys.")
                ,mmm:key))
       (setf (alist-get ,mmm:key ,mmm:alist) ,value)
       (when ,set-existing?
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))


(defmacro int<keyboard>:alist:update/quoted (key value alist &optional set-existing?)
  "Set/overwrite an entry in the alist without evaluating VALUE.

If VALUE is nil, it will be set as KEY's value. Use
`int<keyboard>:alist:delete' if you want to remove it.

Returns ALIST."
  ;; (declare (indent defun))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist:general"))
        (mmm:key   (make-symbol "alist:general/key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (when (stringp ,mmm:key)
         (int<keyboard>:output :error
                               "int<keyboard>:alist:update"
                               '("String key '%s' won't work... "
                                 "Use `int<keyboard>:alist/string:update' for string keys.")
                               ,mmm:key))
       (setf (alist-get ,mmm:key ,mmm:alist) value)
       (when ,set-existing?
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))


;; Currently unused.
(defmacro int<keyboard>:alist:delete (key alist &optional set-existing?)
  "Removes KEY from ALIST.

Returns ALIST."
  ;;(declare (indent defun))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist:general"))
        (mmm:key   (make-symbol "alist:general/key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (when (stringp ,mmm:key)
         (int<keyboard>:output :error
                               "int<keyboard>:alist:update"
                               '("String key '%s' won't work... "
                                 "Use `int<keyboard>:alist/string:update' "
                                 "for string keys.")
                               ,mmm:key))
       (setf (alist-get ,mmm:key ,mmm:alist nil 'remove) nil)
       (when ,set-existing?
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))
;; (let ((alist '((foo . bar))))
;;   (int<keyboard>:alist:delete "foo" alist)
;;   alist)


;;------------------------------------------------------------------------------
;; String Alists
;;------------------------------------------------------------------------------
;; Currently all unused and untested.
;;------------------------------

;; (defun int<keyboard>:alist/string:get/value (key alist &optional default)
;; "Get cdr of KEY's entry in ALIST.
;;
;; If KEY is not in the alist, nil or DEFAULT will be returned."
;; (when (not (stringp key))
;; (int<keyboard>:output :error
;;                         "int<keyboard>:alist/string:get/value"
;;                         '("Only string keys allowed. "
;;                         "Use `int<keyboard>:alist:get/value' for non-string keys.")))
;; (alist-get key alist default nil #'string=))
;;
;;
;; (defun int<keyboard>:alist/string:get/pair (key alist)
;; "Get full assoc/entry of KEY in ALIST."
;; (when (not (stringp key))
;; (int<keyboard>:output :error
;;                         "int<keyboard>:alist/string:get/pair"
;;                         '("Only string keys allowed. "
;;                         "Use `int<keyboard>:alist:get/pair' for non-string keys.")))
;; (assoc key alist #'string=))
;;
;;
;; (defmacro int<keyboard>:alist/string:update (key value alist &optional set-existing?)
;; "Set/overwrite an entry in the alist.
;;
;; If VALUE is nil, it will be set as KEY's value. Use `int<keyboard>:alist/string:delete' if
;; you want to remove it.
;;
;; Returns ALIST."
;; ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
;; (let ((mmm:alist (make-symbol "alist:string"))
;;         (mmm:key   (make-symbol "alist/string:key")))
;; ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
;; ;; Eval inputs once.
;; `(let ((,mmm:alist ,alist)
;;         (,mmm:key ,key))
;; ;;---
;; ;; Error Checking
;; ;;---
;; (when (not (stringp ,mmm:key))
;;         (int<keyboard>:output :error
;;                         "int<keyboard>:alist/string:update"
;;                         '("Only string keys allowed. "
;;                                 "Use `int<keyboard>:alist:update' for non-string key %S.")
;;                         ,mmm:key))
;;
;; (setf (alist-get ,mmm:key ,mmm:alist nil nil #'string=) ,value)
;; (when ,set-existing?
;;         (setq ,alist ,mmm:alist))
;; ,mmm:alist)))
;; ;; (let ((alist '(("foo" . bar))))
;; ;;   (int<keyboard>:alist/string:update "foo" 'baz alist))
;;
;;
;; (defmacro int<keyboard>:alist/string:update/quoted (key value alist &optional set-existing?)
;; "Set/overwrite an entry in the alist without evaluating VALUE.
;;
;; If VALUE is nil, it will be set as KEY's value. Use `int<keyboard>:alist/string:delete' if
;; you want to remove it.
;;
;; Returns ALIST."
;; ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
;; (let ((mmm:alist (make-symbol "alist:string"))
;;         (mmm:key   (make-symbol "alist/string:key")))
;; ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
;; ;; Eval inputs once.
;; `(let ((,mmm:alist ,alist)
;;         (,mmm:key ,key))
;; ;;---
;; ;; Error Checking
;; ;;---
;; (when (not (stringp ,mmm:key))
;;         (int<keyboard>:output :error
;;                         "int<keyboard>:alist/string:update"
;;                         '("Only string keys allowed. "
;;                                 "Use `int<keyboard>:alist:update' for non-string key %S.")
;;                         ,mmm:key))
;;
;; (setf (alist-get ,mmm:key ,mmm:alist nil nil #'string=) value)
;; (when ,set-existing?
;;         (setq ,alist ,mmm:alist))
;; ,mmm:alist)))
;; ;; (let ((alist '(("foo" . bar))))
;; ;;   (int<keyboard>:alist/string:update "foo" 'baz alist))
;;
;;
;; (defmacro int<keyboard>:alist/string:delete (key alist &optional set-existing?)
;; "Removes KEY from ALIST.
;;
;; Returns ALIST."
;; ;; (declare (indent defun))
;;
;; ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
;; (let ((mmm:alist (make-symbol "alist:string"))
;;         (mmm:key   (make-symbol "alist/string:key")))
;; ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
;; ;; Eval inputs once.
;; `(let ((,mmm:alist ,alist)
;;         (,mmm:key ,key))
;; ;;---
;; ;; Error Checking
;; ;;---
;; (when (not (stringp ,mmm:key))
;;         (int<keyboard>:output :error
;;                         "int<keyboard>:alist/string:update"
;;                         '("Only string keys allowed. "
;;                                 "Use `int<keyboard>:alist:update' for non-string key %S.")
;;                         ,mmm:key))
;;
;; (setf (alist-get ,mmm:key ,mmm:alist nil 'remove #'string=) nil)
;; (when ,set-existing?
;;         (setq ,alist ,mmm:alist))
;; ,mmm:alist)))
;; ;; (let ((alist '(("foo" . bar))))
;; ;;   (int<keyboard>:alist/string:delete "foo" alist)
;; ;;   alist)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
