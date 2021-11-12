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
;; Output Message Prefixes
;;------------------------------------------------------------------------------

(defconst int<keyboard>:output:message/prefix
  '((:error . "[ERROR] ':input/keyboard': ")
    (:warn  . "[WARN ] ':input/keyboard': ")
    ;; Noticibly different so when debugging any error/warning messages stand out if all sent to the same buffer?
    (:debug . "<<<debug>>> "))
  "Prefixes for output messages per verbosity level.")


;;------------------------------------------------------------------------------
;; Verbosity
;;------------------------------------------------------------------------------
;; This allows our tests to take over output easier.
;;------------------------------

(defconst int<keyboard>:output:verbose//default-value
  '((:error . t)
    (:warn  . t)
    (:debug . t))
  "Verbosity of various log levels for the ':keyboard' module.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defvar int<keyboard>:output:verbose
  (copy-alist int<keyboard>:output:verbose//default-value)
  "Verbosity of various log levels for the ':keyboard' module.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")
;; (alist-get :error int<keyboard>:output:verbose)


(defconst int<keyboard>:output:default//default-value
  '((:error . error)
    (:warn  . warn)
    (:debug . message))
  "Verbosity of various log levels for the ':keyboard' module.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defvar int<keyboard>:output:default
  (copy-alist int<keyboard>:output:default//default-value)
  "Verbosity of various log levels for the ':keyboard' module.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defun int<keyboard>:output:vars/reset ()
  "Reset output vars to their default values."
  (setq int<keyboard>:output:verbose (copy-alist int<keyboard>:output:verbose//default-value)
        int<keyboard>:output:default (copy-alist int<keyboard>:output:default//default-value)))
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
      ;; Use several specified function.
      ((and (pred listp)
            (pred (lambda (verbosity) (seq-reduce (lambda (reduction element)
                                                    "Allow either functions to call or `t' for 'call the default thing too'."
                                                    (and reduction
                                                         (or (functionp element) (eq element t))))
                                                  verbosity
                                                  #'identity))))
       (dolist (func verbosity)
         (if (eq func t)
             ;; Do the default thing.
             (apply func/default msg args)
           ;; Call the specified function.
           (apply func msg args))))

      ;; Use the specified function.
      ((pred functionp)
       (apply verbosity msg args))

      ;;------------------------------
      ;; Errors/Invalids
      ;;------------------------------
      (:does-not-exist
       ;; Didn't find LEVEL in `int<keyboard>:output:verbose'.
       (error (concat "int<keyboard>:output:output: "
                      "Ouput function for verbosity level doesn't exist; don't know how to output message.\n"
                      "  verbosity level:    %S\n"
                      "  '%S' func:      %S\n"
                      "  existing 'verbose': %S\n"
                      "  existing 'default': %S\n"
                      "  message: %s")
              level
              level
              verbosity
              int<keyboard>:output:verbose
              int<keyboard>:output:default
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

(defun int<keyboard>:output:format (level caller &rest message-format)
  "Combines CALLER and error MESSAGE-FORMAT into one string for sending to
`error' with MESSAGE-FORMAT's args.

NOTE: Is just for the formatting /message/. Args should be passed to `error', `warn',
etc. Or, best: use `int<keyboard>:output'.

Proper use:
  (int<keyboard>:output :error
                        \"int<keyboard>:example-function\"
                        '(\"Imagine this '%s' is a long \"
                          \"error string: %S %d\")
                        some-string something some-integer)
    -> \"[ERROR] ':input/keyboard/layout': int<keyboard>:example-function: <...>\"

Alternative/direct use:
  (error (int<keyboard>:output:format
          \"int<keyboard>:example-function\"
          \"Imagine this '%s' is a long \"
          \"error string: %S %d\")
          some-string something some-integer)
    -> \"[ERROR] ':input/keyboard/layout': int<keyboard>:example-function: <...>\""
  (apply #'concat
         (alist-get level int<keyboard>:output:message/prefix)
         caller
         ": "
         message-format))


(defun int<keyboard>:output (level caller formatting &rest args)
  "Format to standard ':keyboard' message output with CALLER info, then output
the message with FORMATTING and ARGS to the correct place according to LEVEL's
current verbosity (e.g. #'error for `:error' verbosity normally).

For valid LEVELs, see `int<keyboard>:output:verbose' keywords.

Uses FORMATTING string/list-of-strings with `int<keyboard>:output:format' to create
the message format, then applies that format plus any ARGS to the `error'
signaled."
  ;; Try to be real forgiving about what params are since we're erroring...
  ;; ...but also try to let them know they did something wrong so it can be fixed.

  ;;------------------------------
  ;; Validate Inputs
  ;;------------------------------
  (unless (stringp caller)
    (int<keyboard>:output/message
     :warn
     "int<keyboard>:output: invalid CALLER parameter! Should be a string, got: type: %S, value: %S, stringp?: %S"
     (list (type-of caller)
           caller
           (stringp caller))))
  (unless (or (stringp formatting) (listp formatting))
    (int<keyboard>:output/message
     :warn
     "int<keyboard>:output: invalid FORMATTING parameter! Should be a list or a string, got: type: %S, value: %S, string/list?: %S"
     (list (type-of formatting)
           formatting
           (or (stringp formatting) (listp formatting)))))

  ;;------------------------------
  ;; Output a Message
  ;;------------------------------
  (cond
   ;;---
   ;; Valid formatting.
   ;;---
   ((listp formatting)
    (int<keyboard>:output/message level
                                  (apply #'int<keyboard>:output:format level caller formatting)
                                  args))

   ((stringp formatting)
    (int<keyboard>:output/message level
                                  (int<keyboard>:output:format level caller formatting)
                                  args))

   ;;---
   ;; Invalid formatting.
   ;;---
   ;; Do your best to get something.
   (t
    (int<keyboard>:output/message
     :error
     (int<keyboard>:output:format
      level
      caller
      (format "Invalid FORMATTING - expected list or strig. formatting: '%S', args: '%S'"
              formatting args)))

    ;; Don't return `int<keyboard>:output/message' output.
    ;; Unit tests will disable error signaling sometimes so it's best if this returns nil.
    nil)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; (imp:provide :input 'keyboard 'output)
