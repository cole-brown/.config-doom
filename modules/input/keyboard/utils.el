;;; input/keyboard/utils.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Keyboard Layouts                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Not everyone uses Qwerty - there are dozens of us!             ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Utility Functions & Such That Don't Really Fit Elsewhere
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
  ;; Remove keyword's leading ":"?
  (string-remove-prefix
   ":"
   ;; Remove the rest of module flag's leading "+layout/"?
   (string-remove-prefix
    "layout/"
    ;; Remove leading "+" from layout dir name or module flag.
    (string-remove-prefix
     "+"
     (if (stringp input)
         input
       (symbol-name input))))))
;; (int<keyboard>:normalize->string '+layout/spydez)
;; (int<keyboard>:normalize->string :spydez)
;; (int<keyboard>:normalize->string "spydez")
;; (int<keyboard>:normalize->string "+spydez")


(defun int<keyboard>:normalize->keyword (input)
  "Convert INPUT to a keyboard layout keyword.

If INPUT is:
  - Keyword: It is returned as is.
  - nil:     nil will be returned (allows for default args).

Otherwise INPUT is normalized to a string and then converted to a keyword.

E.g. `+layout/dvorak' -> `:dvorak'."
  (cond ((null input)
         nil)
        ((keywordp input)
         input)
        (t
         (intern (concat ":"
                         (int<keyboard>:normalize->string input))))))
;; (int<keyboard>:normalize->keyword '+layout/spydez)
;; (int<keyboard>:normalize->keyword :spydez)
;; (int<keyboard>:normalize->keyword "spydez")
;; (int<keyboard>:normalize->keyword nil)


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'utils)
