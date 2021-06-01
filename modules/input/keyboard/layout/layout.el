;;; input/keyboard/layout/layout.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Validity
;;------------------------------------------------------------------------------

(defun input//kl:layout:valid/keymap? (keymap)
  "Returns `t' if KEYMAP a is valid.
'Valid' is a: symbol, nil, `global', or `:global'."
  (cond ((memq keymap '(nil global :global))
         ;; These all mean 'the global keymap'.
         t)
        ((symbolp keymap)
         ;; These could be for things that aren't loaded yet so don't think we
         ;; can do any additional checks.
         t)
        (t
         (error (concat "input//kl:layout:valid/keymap?: "
                        "KEYMAP '%S' is not valid.")
                keymap))))


(defun input//kl:layout:valid/keyword? (keyword)
  "Is KEYWORD a keyword and is it a valid keyboard layout keyword?"
  (keywordp keyword)
  ;; TODO: "and is it a valid keyboard layout keyword?"
  )


(defun input//kl:layout:valid/keybind? (keybind)
  "Is KEYBIND a string and is it a valid keybinding string?"
  (stringp keybind)
  ;; TODO: "and is it a valid keybinding string?"
  )


(defun input//kl:layout:valid/function? (func)
  "Is FUNC a symbol or function symbol and is it a valid keybinding function?
FUNC is optional, so `nil' is valid."
  (or (null func)
      (and (symbolp func)
           (not (keywordp func))
           ;; Could get something that is not defined yet? In which case this
           ;; causes us to say it's invalid:
           ;; (functionp func)
           ;;
           ;; TODO: "and is it a valid keybinding function?"
           )))


;;------------------------------------------------------------------------------
;; Normalization
;;------------------------------------------------------------------------------

(defun input//kl:layout:normalize/keymap (keymap)
  "In general, returns KEYMAP as-is.

Will convert `nil' and `global' to `:global'."
  (cond
   ;;---
   ;; Invalid KEYMAP
   ;;---
   ((not (input//kl:layout:valid/keymap? keymap))
    ;; `input//kl:layout:valid/keymap?' should have errored but:
    (error (concat "input//kl:layout:normalize/keymap: "
                   "KEYMAP '%S' is not valid.")
           keymap))

   ;;---
   ;; Synonyms
   ;;---
   ((memq keymap '(nil global :global))
    ;; These all mean 'the global keymap' and we'll normalize to `:global'.
    :global)

   ;;---
   ;; (Expected) Default: Return as-is.
   ;;---
   ((symbolp keymap)
    keymap)

   ;;---
   ;; (Unexpected) Default: "...IDK what's going on" error.
   ;;---
   (t
    (error (concat "input//kl:layout:normalize/keymap: "
                   "KEYMAP '%S' fell through all valid checks "
                   "- cannot normalize.")
           keymap))))


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
