;;; input/keyboard/alist.el -*- lexical-binding: t; -*-

;; Helper functions for alists that follow a convention for naming and stuff.
;; And will assist you in keeping you alist up-to-date, like it's a variable
;; or something.


;;------------------------------------------------------------------------------
;; A-list functions that are sane.
;;------------------------------------------------------------------------------

(defun input//kl:alist/get (key alist)
  "Get cdr of KEY's entry in ALIST."
  (alist-get key alist))


(defmacro input//kl:alist/update (key value alist &optional set-alist)
  "Set/overwrite an entry in the alist.

If VALUE is nil, it will be set as KEY's value. Use
`input//kl:alist/delete' if you want to remove it.

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
         (error (input//kl:error-message "input//kl:alist/update"
                                         "String key '%s' won't work... "
                                         "Use `input//kl:alist/string/update' for string keys.")
                ,mmm:key))
       (setf (alist-get ,mmm:key ,mmm:alist) ,value)
       (when ,set-alist
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))


(defmacro input//kl:alist/update-quoted (key value alist &optional set-alist)
  "Set/overwrite an entry in the alist without evaluating VALUE.

If VALUE is nil, it will be set as KEY's value. Use
`input//kl:alist/delete' if you want to remove it.

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
         (error (input//kl:error-message "input//kl:alist/update"
                                         "String key '%s' won't work... "
                                         "Use `input//kl:alist/string/update' for string keys.")
                ,mmm:key))
       (setf (alist-get ,mmm:key ,mmm:alist) value)
       (when ,set-alist
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))


(defmacro input//kl:alist/delete (key alist &optional set-alist)
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
         (error (input//kl:error-message "input//kl:alist/update"
                                         "String key '%s' won't work... "
                                         "Use `input//kl:alist/string/update' "
                                         "for string keys.")
                ,mmm:key))
       (setf (alist-get ,mmm:key ,mmm:alist nil 'remove) nil)
       (when ,set-alist
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))
;; (let ((alist '((foo . bar))))
;;   (input//kl:alist/delete "foo" alist)
;;   alist)


;;------------------------------------------------------------------------------
;; String Alists
;;------------------------------------------------------------------------------

(defun input//kl:alist/string/get (key alist &optional default)
  "Get cdr of KEY's entry in ALIST.

If KEY is not in the alist, nil or DEFAULT will be returned."
  (when (not (stringp key))
    (error (input//kl:error-message "input//kl:alist/string/get"
                                    "Only string keys allowed. "
                                    "Use `input//kl:alist/get' for non-string keys.")))
  (alist-get key alist default nil #'string=))


(defmacro input//kl:alist/string/update (key value alist &optional set-alist)
  "Set/overwrite an entry in the alist.

If VALUE is nil, it will be set as KEY's value. Use `input//kl:alist/string/delete' if
you want to remove it.

Returns ALIST."
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist:string"))
        (mmm:key   (make-symbol "alist:string/key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (when (not (stringp ,mmm:key))
         (error (input//kl:error-message "input//kl:alist/string/update"
                                         "Only string keys allowed. "
                                         "Use `input//kl:alist/update' for non-string key %S.")
                ,mmm:key))

       (setf (alist-get ,mmm:key ,mmm:alist nil nil #'string=) ,value)
       (when ,set-alist
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))
;; (let ((alist '(("foo" . bar))))
;;   (input//kl:alist/string/update "foo" 'baz alist))


(defmacro input//kl:alist/string/update-quoted (key value alist &optional set-alist)
  "Set/overwrite an entry in the alist without evaluating VALUE.

If VALUE is nil, it will be set as KEY's value. Use `input//kl:alist/string/delete' if
you want to remove it.

Returns ALIST."
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist:string"))
        (mmm:key   (make-symbol "alist:string/key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (when (not (stringp ,mmm:key))
         (error (input//kl:error-message "input//kl:alist/string/update"
                                         "Only string keys allowed. "
                                         "Use `input//kl:alist/update' for non-string key %S.")
                ,mmm:key))

       (setf (alist-get ,mmm:key ,mmm:alist nil nil #'string=) value)
       (when ,set-alist
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))
;; (let ((alist '(("foo" . bar))))
;;   (input//kl:alist/string/update "foo" 'baz alist))


(defmacro input//kl:alist/string/delete (key alist &optional set-alist)
  "Removes KEY from ALIST.

Returns ALIST."
  ;; (declare (indent defun))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist:string"))
        (mmm:key   (make-symbol "alist:string/key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (when (not (stringp ,mmm:key))
         (error (input//kl:error-message "input//kl:alist/string/update"
                                         "Only string keys allowed. "
                                         "Use `input//kl:alist/update' for non-string key %S.")
                ,mmm:key))

       (setf (alist-get ,mmm:key ,mmm:alist nil 'remove #'string=) nil)
       (when ,set-alist
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))
;; (let ((alist '(("foo" . bar))))
;;   (input//kl:alist/string/delete "foo" alist)
;;   alist)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
