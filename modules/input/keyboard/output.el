;;; input/keyboard/error.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                               Error Help                               ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                  Delete if you can make error-proof code.                  ;;
;;                                 ──────────                                 ;;

(require 'seq)


;;------------------------------------------------------------------------------
;; Keyboard keybind -> "C-x M-c M-butterfly"
;;------------------------------------------------------------------------------

(defun int<keyboard>:output:normalize/key (key)
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
       (warn "int<keyboard>:output:normalize/key: Not a valid key string/keybind! %S -> %S"
             key signal-raised)
       ;; 2) any string will do
       (format "%S" key)))))
;; (int<keyboard>:output:normalize/key "C-x C-c")
;; (int<keyboard>:output:normalize/key '[RET])
;; (int<keyboard>:output:normalize/key '(invalid . thing))


;;------------------------------------------------------------------------------
;; Verbosity
;;------------------------------------------------------------------------------
;; This allows our tests to take over output easier.
;;------------------------------

(defvar int<keyboard>:output:verbose
  '((:error . t)
    (:warn  . t)
    (:debug . t))
  "Verbosity of various log levels for the ':keyboard' module.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")
;; (alist-get :error int<keyboard>:output:verbose)


(defvar int<keyboard>:output:default
  '((:error . error)
    (:warn  . warn)
    (:debug . message))
  "Verbosity of various log levels for the ':keyboard' module.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


;;---
;; Save the default values to a symbol property.
;; This allows the unit tests to reset it easily.
;;---
(put 'int<keyboard>:output:verbose :default (copy-alist int<keyboard>:output:verbose))
(put 'int<keyboard>:output:default :default (copy-alist int<keyboard>:output:default))


(defun int<keyboard>:output:vars/reset ()
  "Reset output vars to their default values."
  (setq int<keyboard>:output:verbose (get 'int<keyboard>:output:verbose :default)
        int<keyboard>:output:default (get 'int<keyboard>:output:default :default)))
;; (setq int<keyboard>:output:verbose nil)
;; (int<keyboard>:output:vars/reset)


(defun int<keyboard>:output/message (level msg args)
  "Decides how to output LEVEL keyword (`int<keyboard>:output:verbose') MSG and
ARGS based on current verbosity for the level."
  (let ((func/default (alist-get level int<keyboard>:output:default :does-not-exist))
        (verbosity    (alist-get level int<keyboard>:output:verbose :does-not-exist)))
    ;; Should complain about no default.
    (when (eq func/default :does-not-exist)
      (error (concat "int<keyboard>:output:output: "
                     "Verbosity for '%S' is '%S', and we don't have a default output function in %S for that. "
                     "Output Message:\n%s")
             level
             unknown-value
             'int<keyboard>:output:default
             (apply #'format msg args)))

    ;; Output message depending on LEVEL's current verbosity.
    (pcase verbosity
      ;;------------------------------
      ;; Valid Values
      ;;------------------------------
      ;;---
      ;; Normal on/off
      ;;---
      ('t
       ;; Do the normal/default thing.
       (apply func/default msg args))

      ('nil
       ;; Do nothing
       nil)

      ;;---
      ;; Debugging
      ;;---
      ;; Use the specified function.
      ((pred functionp)
       (apply verbosity msg args))

      ;; Use several specified function.
      ((and (pred listp)
            (pred (lambda (verbosity) (seq-reduce (lambda (element)
                                                    "Allow either functions to call or `t' for 'call the default thing too'."
                                                    (or (functionp element) (eq element t)))
                                                  verbosity
                                                  #'identity))))
       (dolist (func verbosity)
         (if (eq func t)
             ;; Do the default thing.
             (apply func/default msg args)
           ;; Call the specified function.
           (apply func msg args))))

      ;;------------------------------
      ;; Errors/Invalids
      ;;------------------------------
      (:does-not-exist
       ;; Didn't find LEVEL in `int<keyboard>:output:verbose'.
       (error (concat "int<keyboard>:output:output: "
                      "Verbosity level '%S' doesn't exist; don't know how to output message:\n%s ")
              level
              unknown-value
              (apply #'format msg args)))

      (unknown-value
       ;; Found LEVEL, but don't know what to do with its value.
       (error (concat "int<keyboard>:output:output: "
                      "Verbosity for '%S' is '%S', and we don't know what to do with that. "
                      "Output Message:\n%s")
              level
              unknown-value
              (apply #'format msg args))))))


;;------------------------------------------------------------------------------
;; Output API - Errors, Warnings, etc
;;------------------------------------------------------------------------------

(defun int<keyboard>:output:format (caller &rest message-format)
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


;; TODO: Rework all the calls to use new  `int<keyboard>:output' instead.
(defalias 'int<keyboard>:error/format 'int<keyboard>:output:format)


(defun int<keyboard>:output (caller level formatting &rest args)
  "Format to standard ':keyboard' message output with CALLER info, then output
the message with FORMATTING and ARGS to the correct place according to LEVEL's
current verbosity (e.g. #'error for `:error' verbosity normally).

For valid LEVELs, see `int<keyboard>:output:verbose' keywords.

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
      (int<keyboard>:output/message
       :warn
       "int<keyboard>:output: invalid CALLER parameter! Should be a string, got: '%s'"
       caller))
    (when (not valid/formatting)
      (int<keyboard>:output/message
       :warn
       "int<keyboard>:output: invalid FORMATTING parameter! Should be a list or a string, got: '%s'"
       formatting))

    ;; Now raise the error signal.
    (cond
     ;;---
     ;; Valid formatting.
     ;;---
     ((listp formatting)
      (int<keyboard>:output/message level
                                    (apply #'int<keyboard>:output:format caller formatting)
                                    args))

     ((stringp formatting)
      (int<keyboard>:output/message level
                                    (int<keyboard>:output:format caller formatting)
                                    args))

     ;;---
     ;; Invalid formatting.
     ;;---
     ;; Do your best to get something.
     (t
      (int<keyboard>:output/message
       :error
       (int<keyboard>:output:format
        caller
        (format "Invalid FORMATTING - expected list or strig. formatting: '%S', args: '%S'"
                formatting args)))))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
