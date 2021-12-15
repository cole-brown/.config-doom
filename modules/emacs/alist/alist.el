;;; alist/alist.el -*- lexical-binding: t; -*-

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
(imp:require :alist 'internal)


;;------------------------------------------------------------------------------
;; A-list functions that are sane.
;;------------------------------------------------------------------------------

(defun alist:alist? (item)
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


(defun alist:copy/shallow (alist)
  "Returns a shallow copy of ALIST.

Copies the ALIST so that the returned alist does not share structure with
the input. Does not copy the keys/values (not a deep copy)."
  (copy-alist alist))


(defun alist:get/value (key alist &optional default)
  "Get cdr of KEY's entry in ALIST."
  (alist-get key alist default))


(defun alist:get/pair (key alist)
  "Get full assoc/entry of KEY in ALIST."
  (assoc key alist))


(defun int<alist>:update/helper (key value alist)
  "Set/overwrite an entry in the ALIST. Return the new alist.

If VALUE is nil, it will be set as KEY's value. Use
`alist:delete' if you want to remove it.

Returns a new alist, which isn't ALIST."
  ;;---
  ;; Error Checking
  ;;---
  (when (stringp key)
    (int<alist>:error "alist:update"
                      '("String key '%s' won't work... "
                        "Use `alist:string:update' for string keys.")
                      key))

  (if (null alist)
      ;; Create a new alist and return it.
      (list (cons key value))

    ;; `setf' creates a new alist sometimes, so buyer beware!
    (setf (alist-get key alist) value)
    alist))
;; (setq test-alist nil)
;; (setq test-alist (int<alist>:update/helper :k :v test-alist))
;; (int<alist>:update/helper :k2 :v2 test-alist)
;; (int<alist>:update/helper :k2 :v2.0 test-alist)
;; test-alist


(defmacro alist:update (key value alist)
  "Set/overwrite an entry in the ALIST.

SYMBOL/ALIST should be a (quoted) symbol so that this can update it directly.

If VALUE is nil, it will be set as KEY's value. Use
`alist:delete' if you want to remove it.

Returns ALIST."
  `(let ((mmm:alist ,alist))
     (cond
      ((listp mmm:alist)
       (setq ,alist
             (int<alist>:update/helper ,key ,value ,alist)))
      ((symbolp mmm:alist)
       (set mmm:alist
            (int<alist>:update/helper ,key ,value (eval mmm:alist))))

      (t
       (int<alist>:error "alist:update"
                         "Unable to update alist with type %S: %S"
                         (typeof mmm:alist) mmm:alist)))))
;; A global variable:
;;   (setq test-alist nil)
;;   (alist:update :k :v test-alist)
;;   (alist:update :k :v test-alist)
;;   (alist:update :k2 :v2 test-alist)
;;   (alist:update :k2 :v2.0 test-alist)
;;   test-alist
;;
;; A scoped variable:
;;   (let (test-alist/let)
;;     (alist:update :k :v test-alist/let)
;;     (alist:update :k2 :v2 test-alist/let)
;;     (alist:update :k2 :v2.0 test-alist/let)
;;     test-alist/let)
;;
;; A +function+ macro call in the macro call:
;;   - Needs `test<alist/alist>:alist:get' and `test<alist/alist>:alist/nil' from 'test/alist.el'.
;; (setq test<alist/alist>:alist/nil nil)
;; test<alist/alist>:alist/nil
;; (alist:update :k :v
;;               (test<alist/alist>:alist:get :global/nil))
;; test<alist/alist>:alist/nil


(defun int<alist>:delete/helper (key alist)
  "Removes KEY from ALIST.

Returns alist without the key."
  ;;---
  ;; Error Checking
  ;;---
  (when (stringp key)
    (int<alist>:error "alist:delete"
                      '("String key '%s' won't work... "
                        "Use `alist:string:delete' "
                        "for string keys.")
                      key))
  ;; If it's null, no need to do anything.
  (unless (null alist)
    (setf (alist-get key alist nil 'remove) nil))

  ;; Return the alist.
  alist)


(defmacro alist:delete (key alist)
  "Removes KEY from ALIST.

Returns ALIST."
  `(let ((mmm:alist ,alist))
     (cond
      ((listp mmm:alist)
       (setq ,alist
             (int<alist>:delete/helper ,key ,alist)))
      ((symbolp mmm:alist)
       (set mmm:alist
            (int<alist>:delete/helper ,key (eval mmm:alist))))

      (t
       (int<alist>:error "alist:delete"
                         "Unable to delete key from alist with type %S: %S"
                         (typeof mmm:alist) mmm:alist)))))
;; (setq test-alist nil)
;; (alist:delete :k test-alist)
;; (alist:update :k :v test-alist)
;; (alist:delete :k2 test-alist)
;; (alist:delete :k test-alist)
;; test-alist


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :alist 'alist)
