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

(require 'seq)

(imp:require :input 'keyboard 'output)


;;------------------------------------------------------------------------------
;; A-list functions that are sane.
;;------------------------------------------------------------------------------

(defun int<keyboard>:alist:alist? (item)
  "Returns non-nil if ITEM is an alist.

If ITEM is nil, returns `t', because:
  1. We cannot be sure it's /NOT/ an alist.
  2. `nil' is a valid list, and an empty list is a valid alist."
  ;; We'll consider `nil' a valid alist.
  (cond (nil
         t)

        ;; An alist has to be a list.
        ((not (listp item))
         nil)

        ;; An alist has to have only lists (or cons, which are lists).
        ;; If this is truthy, we'll just return its truthiness.
        ((seq-every-p #'listp item))

        (t
         nil)))


(defun int<keyboard>:alist:get/value (key alist)
  "Get cdr of KEY's entry in ALIST."
  (alist-get key alist))


(defun int<keyboard>:alist:get/pair (key alist)
  "Get full assoc/entry of KEY in ALIST."
  (assoc key alist))


(defun int<keyboard>:alist:update/helper (key value alist)
  "Set/overwrite an entry in the ALIST. Return the new alist.

If VALUE is nil, it will be set as KEY's value. Use
`int<keyboard>:alist:delete' if you want to remove it.

Returns a new alist, which isn't ALIST."
  ;;---
  ;; Error Checking
  ;;---
  (when (stringp key)
    (int<keyboard>:output :error
                          "int<keyboard>:alist:update"
                          '("String key '%s' won't work... "
                            "Use `int<keyboard>:alist/string:update' for string keys.")
                          key))

  (if (null alist)
      ;; Create a new alist and return it.
      (list (cons key value))

    ;; `setf' creates a new alist sometimes, so buyer beware!
    (setf (alist-get key alist) value)
    alist))
;; (setq test-alist nil)
;; (setq test-alist (int<keyboard>:alist:update/helper :k :v test-alist))
;; (int<keyboard>:alist:update/helper :k2 :v2 test-alist)
;; (int<keyboard>:alist:update/helper :k2 :v2.0 test-alist)
;; test-alist


(defmacro int<keyboard>:alist:update (key value alist)
  "Set/overwrite an entry in the ALIST.

SYMBOL/ALIST should be a (quoted) symbol so that this can update it directly.

If VALUE is nil, it will be set as KEY's value. Use
`int<keyboard>:alist:delete' if you want to remove it.

Returns ALIST."
  `(let ((mmm:alist ,alist))
     (cond
      ((listp mmm:alist)
       (setq ,alist
             (int<keyboard>:alist:update/helper ,key ,value ,alist)))
      ((symbolp mmm:alist)
       (set mmm:alist
            (int<keyboard>:alist:update/helper ,key ,value (eval mmm:alist))))

      (t
       (int<keyboard>:output :error
                             "int<keyboard>:alist:update"
                             "Unable to update alist with type %S: %S"
                             (typeof mmm:alist) mmm:alist)))))
;; A global variable:
;;   (setq test-alist nil)
;;   (int<keyboard>:alist:update :k :v test-alist)
;;   (int<keyboard>:alist:update :k :v test-alist)
;;   (int<keyboard>:alist:update :k2 :v2 test-alist)
;;   (int<keyboard>:alist:update :k2 :v2.0 test-alist)
;;   test-alist
;;
;; A scoped variable:
;;   (let (test-alist/let)
;;     (int<keyboard>:alist:update :k :v test-alist/let)
;;     (int<keyboard>:alist:update :k2 :v2 test-alist/let)
;;     (int<keyboard>:alist:update :k2 :v2.0 test-alist/let)
;;     test-alist/let)
;;
;; A +function+ macro call in the macro call:
;;   - Needs `test<keyboard/alist>:alist:get' and `test<keyboard/alist>:alist/nil' from 'test/alist.el'.
;; (setq test<keyboard/alist>:alist/nil nil)
;; test<keyboard/alist>:alist/nil
;; (int<keyboard>:alist:update :k :v
;;                             (test<keyboard/alist>:alist:get :global/nil))
;;  test<keyboard/alist>:alist/nil



(defun int<keyboard>:alist:delete/helper (key alist)
  "Removes KEY from ALIST.

Returns alist without the key."
  ;;---
  ;; Error Checking
  ;;---
  (when (stringp key)
    (int<keyboard>:output :error
                          "int<keyboard>:alist:delete"
                          '("String key '%s' won't work... "
                            "Use `int<keyboard>:alist/string:delete' "
                            "for string keys.")
                          key))
  ;; If it's null, no need to do anything.
  (unless (null alist)
    (setf (alist-get key alist nil 'remove) nil))

  ;; Return the alist.
  alist)


(defmacro int<keyboard>:alist:delete (key alist)
  "Removes KEY from ALIST.

Returns ALIST."
  `(let ((mmm:alist ,alist))
     (cond
      ((listp mmm:alist)
       (setq ,alist
             (int<keyboard>:alist:delete/helper ,key ,alist)))
      ((symbolp mmm:alist)
       (set mmm:alist
            (int<keyboard>:alist:delete/helper ,key (eval mmm:alist))))

      (t
       (int<keyboard>:output :error
                             "int<keyboard>:alist:delete"
                             "Unable to delete key from alist with type %S: %S"
                             (typeof mmm:alist) mmm:alist)))))
;; (setq test-alist nil)
;; (int<keyboard>:alist:delete :k test-alist)
;; (int<keyboard>:alist:update :k :v test-alist)
;; (int<keyboard>:alist:delete :k2 test-alist)
;; (int<keyboard>:alist:delete :k test-alist)
;; test-alist


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
;; TODO: redo as defun like `int<keyboard>:alist:update'.
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
;; TODO: redo as defun like `int<keyboard>:alist:delete'.
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
(imp:provide :input 'keyboard 'alist)
