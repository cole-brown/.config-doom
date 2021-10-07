;;; input/keyboard/error.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                               Error Help                               ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                  Delete if you can make error-proof code.                  ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Keyboard keybind -> "C-x M-c M-butterfly"
;;------------------------------------------------------------------------------

(defun int<keyboard>:error:normalize/key (key)
  "Normalizes KEY to a human-friendly string for a debug message."
  (if (stringp key)
      ;; String is ok as-is.
      key
    ;; Convert any error into a warning since we're probably trying to do an error message ourselves.
    (condition-case signal-raised
        (key-description key)
      ;; That raised some sort of signal, so... backup plan:
      (t
       ;; 1) warn
       (warn "int<keyboard>:error:normalize/key: Not a valid key string/keybind! %S -> %S"
             key signal-raised)
       ;; 2) any string will do
       (format "%S" key)))))
;; (int<keyboard>:error:normalize/key "C-x C-c")
;; (int<keyboard>:error:normalize/key '[RET])
;; (int<keyboard>:error:normalize/key '(invalid . thing))
;;    ;;------------------------------
;;    ;; Didn't work?!
;;    ;;------------------------------
;;    ;; Try to make a nice string from the keybind.
;;    ;; Can't use `condition-case-unless-debug' because you can't catch-all with `t'?
;;    ;; So I guess try it this way?
;;    (if debug-on-error  ;; FIXME: um... why is this `t' regardless of actual value of `debug-on-error'?!
;;        ;; Try it and let any error happen.
;;        (key-description key)
;;      ;; Convert any error into a warning since we're probably trying to do an error message ourselves.
;;      (condition-case signal-raised
;;          (key-description key)
;;        ;; That raised some sort of signal, so... backup plan:
;;        (t
;;         ;; 1) warn
;;         (warn "int<keyboard>:error:normalize/key: Not a valid key string/keybind! %S -> %S"
;;               key signal-raised)
;;         ;; 2) any string will do
;;         (format "%S" key)))
;;
;;      )))


;;------------------------------------------------------------------------------
;; Error Helper
;;------------------------------------------------------------------------------

(defun int<keyboard>:error/format (caller &rest message-format)
  "Combines CALLER and error MESSAGE-FORMAT into one string for sending to
`error' with MESSAGE-FORMAT's args.

NOTE: Is just for the error /message/. Args should be passed to `error', `warn',
etc.
  (error (int<keyboard>:error/format
          \"int<keyboard>:example-function\"
          \"Imagine this '%s' is a long \"
          \"error string: %S %d\")
          some-string something some-integer)
    -> \"Doom Module ':input/keyboard/layout': int<keyboard>:example-function: <...>\""
  (apply #'concat
         "Doom Module ':input/keyboard/layout': "
         caller
         ": "
         message-format))


(defun int<keyboard>:error:message (caller formatting &rest args)
  "Raises an error signal with formatted message.

Uses FORMATTING string/list-of-strings with `int<keyboard>:error/format' to create
the message format, then applies that format plus any ARGS to the `error'
signaled."
  ;; Try to be real forgiving about what params are since we're erroring...
  ;; ...but also try to let them know they did something wrong so it can be fixed.
  (let* ((valid/caller (stringp caller))
         (valid/formatting (or (stringp formatting) (listp formatting)))
         (caller (if valid/caller
                     caller
                   (format "%s" caller))))
    ;; First, a warning about any invalid inputs?
    (when (not valid/caller)
      (warn "int<keyboard>:error/format: invalid CALLER parameter! Should be a string, got: '%s'"
            caller))
    (when (not valid/formatting)
      (warn "int<keyboard>:error/format: invalid FORMATTING parameter! Should be a list or a string, got: '%s'"
            formatting))

    ;; Now raise the error signal.
    (cond
     ;;---
     ;; Valid formatting.
     ;;---
     ((listp formatting)
      (error (apply #'int<keyboard>:error/format caller formatting) args))

     ((stringp formatting)
      (error (int<keyboard>:error/format caller formatting) args))

      ;;---
      ;; Invalid formatting.
      ;;---
      ;; Do your best to get something.
      (t
       (error (int<keyboard>:error/format caller
                                      (format "formatting: '%S', args: '%S'"
                                              formatting args)))))))

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
