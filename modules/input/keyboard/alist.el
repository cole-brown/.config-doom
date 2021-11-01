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


(defun int<keyboard>:alist:get/alist (arg)
  "Takes ARG and figures out where its alist is, returns the alist.

ARG can be:
  - an alist/nil
  - a symbol name
  - a function call that returns:
    - an alist/nil
    - a symbol name

Returns a list or nil, or signals an error if it cannot find an alist."
  (cond
   ;; Special case: nil is just nil. Don't go down an infinite rabbit hole of nil symbols/lists.
   ((null arg)
    nil)

   ;; It's a symbol, check out its value.
   ;; Don't use `symbol-value' since it doesn't understand lexical symbols.
   ((symbolp arg)
    (int<keyboard>:alist:get/alist (eval arg)))

   ;; It's a function, check out its return value.
   ;; NOTE: Put before `listp' as funcs can be lists.
   ((functionp arg)
    (int<keyboard>:alist:get/alist (funcall arg)))

   ;; List? Return as-is.
   ((listp arg)
    arg)

   ;; ??? -> error
   (t
    (int<keyboard>:output :error
                          "int<keyboard>:alist:get/alist"
                          '("Cannot figure out what ARG is or where its alist is."
                            "ARG: (type: %S) %S")
                          (type-of arg)
                          arg))))


(defmacro int<keyboard>:alist:update (key value alist)
  "Set/overwrite an entry in the ALIST.

ALIST can be:
  - A list/nil.
  - A symbol name.
  - A function call that returns one of the above.
See: `int<keyboard>:alist:get/alist'

If VALUE is nil, it will be set as KEY's value. Use
`int<keyboard>:alist:delete' if you want to remove it.

Returns ALIST."
  ;; Use our own uninterned symbols that won't interfere.
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist/in (make-symbol "alist:general/alist-in"))
        (mmm:alist    (make-symbol "alist:general/alist-update"))
        (mmm:key      (make-symbol "alist:general/key")))
    ;; Only eval inputs once.
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    `(let* ((,mmm:alist/in (int<keyboard>:alist:get/alist ,alist))
            (,mmm:alist    ,mmm:alist/in)
            (,mmm:key      ,key))
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
       ;; `setf' creates a new alist sometimes, so set the results unless we can't given the input type.
       (if (symbolp ,mmm:alist/in)
           (setq ,mmm:alist/in ,mmm:alist))
       ,mmm:alist)))


;; Currently unused.
(defmacro int<keyboard>:alist:delete (key alist)
  "Removes KEY from ALIST.

Returns ALIST."
  ;;(declare (indent defun))

 ;; Use our own uninterned symbols that won't interfere.
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist/in (make-symbol "alist:general/alist-in"))
        (mmm:alist    (make-symbol "alist:general/alist-update"))
        (mmm:key      (make-symbol "alist:general/key")))
    ;; Only eval inputs once.
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    `(let* ((,mmm:alist/in (int<keyboard>:alist:get/alist ,alist))
            (,mmm:alist    ,mmm:alist/in)
            (,mmm:key      ,key))
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
       ;; `setf' creates a new alist sometimes, so set the results unless we can't given the input type.
       (if (symbolp ,mmm:alist/in)
           (setq ,mmm:alist/in ,mmm:alist))
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
