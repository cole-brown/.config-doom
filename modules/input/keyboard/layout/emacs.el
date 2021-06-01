;;; input/keyboard/layout/emacs.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


(defvar input//kl:definitions:emacs nil
  "Definition of the layout created by calling `input:keyboard/layout:emacs'.

Multiple calls to `input:keyboard/layout:emacs' accumulate the result here.

Format:
  - alist by layout keyword
    - alist by keymap symbol
      - keybinding entries: list of:
        (keybind-keyword keybind-string optional-function)")


;;------------------------------------------------------------------------------
;; Validity
;;------------------------------------------------------------------------------

;; TODO: this is the guts of `input//kl:valid/entry.evil?'. Refactor to be for
;; an emacs entry instead of evil.
;;
;; (defun input//kl:valid/entry.emacs? (entry)
;;   "Returns ENTRY (aka 'non-nil') if ENTRY is valid.

;; Raises an error if it is invalid."
;;   (cond
;;    ;;------------------------------
;;    ;; General Checks
;;    ;;------------------------------
;;    ((null entry)
;;     (error "%s: null entry is not valid: %S"
;;            "input//kl:valid/entry.evil?"
;;            entry)
;;     nil)

;;    ((not (listp entry))
;;     (error "%s: entry must be a list: %S"
;;            "input//kl:valid/entry.evil?"
;;            entry)
;;     nil)

;;    ((and (not (= (length entry) 2))
;;          (not (= (length entry) 3)))
;;     (error "%s: entry must be a list of length 2 or 3: %S"
;;            "input//kl:valid/entry.evil?"
;;            entry)
;;     nil)

;;    ;;------------------------------
;;    ;; Got a list of the right length now - does it have the correct things
;;    ;; in the correct order?
;;    ;;------------------------------
;;    ((not (input//kl:layout:valid/keyword? (nth 0 entry)))
;;     (error "%s: Entry's first element failed keyword validity check: %S"
;;            "input//kl:valid/entry.evil?"
;;            entry)
;;     nil)

;;    ((not (input//kl:layout:valid/keybind? (nth 1 entry)))
;;     (error "%s: Entry's second element failed keybind validity check: %S"
;;            "input//kl:valid/entry.evil?"
;;            entry)
;;     nil)

;;    ;; Ok if optional func in entry is nil.
;;    ((not (input//kl:layout:valid/function? (nth 2 entry)))
;;     (error (concat "%s: Entry's third (and optional) element "
;;                    "failed function validity check: %S")
;;            "input//kl:valid/entry.evil?"
;;            entry)
;;     nil)

;;    ;;------------------------------
;;    ;; Default is: It passed all our failures so it's good.
;;    ;;------------------------------
;;    (t
;;     ;; Could return t, but maybe returning the entry back will help someone
;;     ;; somewhere.
;;     entry)))
