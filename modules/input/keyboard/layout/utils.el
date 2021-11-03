;;; input/keyboard/layout/utils.el -*- lexical-binding: t; -*-

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

(defun int<keyboard>:layout:normalize->func (keyword-or-func)
  "Normalizes a KEYWORD-OR-FUNC to a function."
  ;; "Function" can be nil for unbinding something, so get the entry to check
  ;; for its existance instead.
  (let ((key->func (int<keyboard>:alist:get/pair keyword-or-func
                                                 int<keyboard>:definitions:keywords)))
    (cond
     ;; Did the keyword exist?
     (key->func
      ;; Return its function/nil.
      (cdr key->func))

     ;; Is a keyword; didn't find it. Error.
     ((keywordp keyword-or-func)
      (int<keyboard>:output :error
                            '("int<keyboard>:layout:normalize->func"
                              "No known keyword for %S.")
                            keyword-or-func))

     ;; Assume it was a function already, not a keyword, and return it as-is.
     (t
      keyword-or-func))))
;; (int<keyboard>:layout:normalize->func :layout:evil:line-prev)
;; (int<keyboard>:layout:normalize->func :layout:common:undefined)
;; (int<keyboard>:layout:normalize->func :layout:DNE:should-error)


(defun int<keyboard>:layout:normalize->modifier (symbol)
  "Normalizes a symbol, quoted symbol, or keyword to a modifier keyword."
  (let ((symbol/in (doom-unquote symbol)))
    (cond ((keywordp symbol/in)
           symbol/in)
          ((symbolp symbol/in)
           (intern (concat ":" (symbol-name symbol/in))))
          (t
           (int<keyboard>:output :error
                                 '("int<keyboard>:layout:normalize->modifier"
                                   "Unknown input type: %S. Not a keyword or symbol.")
                                 symbol)))))
;; (int<keyboard>:layout:normalize->modifier ':control)
;; (int<keyboard>:layout:normalize->modifier 'control)
;; (int<keyboard>:layout:normalize->modifier (quote (quote control)))
;; (int<keyboard>:layout:normalize->modifier 'unshift)
;; (int<keyboard>:layout:normalize->modifier 'jeff)
