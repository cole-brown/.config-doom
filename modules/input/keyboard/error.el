;;; input/keyboard/error.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                               Error Help                               ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                  Delete if you can make error-proof code.                  ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Error Helper
;;------------------------------------------------------------------------------

(defun input//kl:error/format (func-name &rest message-format)
  "Combines FUNC-NAME and error MESSAGE-FORMAT into one string for sending to
`error' with MESSAGE-FORMAT's args.

NOTE: Is just for the error /message/. Args should be passed to `error', `warn',
etc.
  (error (input//kl:error/format
          \"input//kl:example-function\"
          \"Imagine this '%s' is a long \"
          \"error string: %S %d\")
          some-string something some-integer)
    -> \"Doom Module ':input/keyboard/layout': input//kl:example-function: <...>\""
  (apply #'concat
         "Doom Module ':input/keyboard/layout': "
         func-name
         ": "
         message-format))


(defun input//kl:error:normalize/key (key)
  "Normalizes KEY to a human-friendly string for a debug message."
  (if (stringp key)
      key
    (key-description key)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
