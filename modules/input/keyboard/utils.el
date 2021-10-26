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
;; States
;;------------------------------------------------------------------------------

(defun int<keyboard>:states->keyword (states)
  "Convert a list of evil STATES symbols into a keyword for `map!'.

The inverse of `doom--map-keyword-to-states'.

For example, (list 'normal 'visual 'insert) will map to `:nvi'. See
`doom-evil-state-alist' to customize this."
  (let (keyword/char-list)
    ;; Convert to list of chararcters...
    (dolist (state states)
      (if-let ((state/char (nth 0 (rassoc (doom-unquote state) doom-evil-state-alist))))
          (push state/char keyword/char-list)
        (error "int<keyboard>:states->keyword: Invalid state: %S" state)))
    ;; And now convert our list of chars into a keyword.
    (if keyword/char-list
        (intern (apply #'string ?: (nreverse keyword/char-list)))
      (error (concat "int<keyboard>:states->keyword: No result from states? "
                     "states: %S -> keyword characters: %S")
             states keyword/char-list))))
;; (int<keyboard>:states->keyword '(normal visual))


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'utils)
