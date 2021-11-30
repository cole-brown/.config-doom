;;; output/nub/utils.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Keyboard Layouts                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Not everyone uses Qwerty - there are dozens of us!             ;;
;;                                 ──────────                                 ;;

(imp:require :input 'keyboard 'output)


;;------------------------------------------------------------------------------
;; Utility Functions & Such That Don't Really Fit Elsewhere
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Normalization
;;------------------------------------------------------------------------------

(defun int<keyboard>:normalize->string (input)
  "Normalize INPUT to a layout string.

If INPUT is:
  - String:  Remove \"+layout/\" prefix,
             (then remove \":\" prefix if exists), and return.
  - Keyword: Get symbol name, remove \":\" prefix, and return.
  - Symbol:  Get symbol name, remove \"+layout/\" prefix,
             (then remove \":\" prefix if exists), and return.
E.g.
  1) \"dvorak\" -> \"dvorak\"
  2) `:dvorak' -> \"dvorak\"
  3) `+layout/dvorak' -> \"dvorak\""
  (replace-regexp-in-string
   ;; Must match start of string.
   (rx string-start
       ;; ':' from keywords (`:dvorak').
       ;; '+' from module flag (`+layout/dvorak').
       (zero-or-one (any ":" "+"))
       ;; 'layout/' from module flag (`+layout/dvorak') or directory path ('layout/+dvorak').
       (zero-or-one "layout/")
       ;; '+' from directory path ('layout/+dvorak').
       (zero-or-one "+"))
   ;; Replace with nothing.
   ""
   ;; Make sure we've got a string (or we've errored out on invalid input type.
   (if (stringp input)
       input
     (symbol-name input))))
;; (int<keyboard>:normalize->string '+layout/spydez)
;; (int<keyboard>:normalize->string :spydez)
;; (int<keyboard>:normalize->string "spydez")
;; (int<keyboard>:normalize->string "+spydez")


(defun int<keyboard>:normalize->keyword (input)
  "Convert INPUT to a keyboard layout keyword.

If INPUT is `nil', `nil' will be returned (allows for default args).

Otherwise INPUT is normalized to a string and then converted to a keyword.
  - Uses `int<keyboard>:normalize->string'.

E.g. `+layout/dvorak' -> `:dvorak'."
  (if (null input)
      nil
    (intern (concat ":"
                    (int<keyboard>:normalize->string input)))))
;; (int<keyboard>:normalize->keyword '+layout/spydez)
;; (int<keyboard>:normalize->keyword :spydez)
;; (int<keyboard>:normalize->keyword "spydez")
;; (int<keyboard>:normalize->keyword nil)


;;------------------------------------------------------------------------------
;; Predicates
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


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'utils)
