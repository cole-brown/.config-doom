;;; output/nub/base.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Error/Warn/Etc.                             ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                  Delete if you can make error-proof code.                  ;;
;;                                 ──────────                                 ;;

(require 'seq)
(imp:require :nub 'internal)
(imp:require :nub 'alist)
(imp:require :nub 'variables)


;;------------------------------------------------------------------------------
;; Output Message Helpers
;;------------------------------------------------------------------------------

(defun int<nub>:output:sinks (level sinks msg args)
  "Output MSG with ARGS to any/all SINKS."
  ;; List of sinks to output to?
  (if (and sinks
           (listp sinks))
      (dolist (sink sinks)
        (int<nub>:output:sink level sink msg args))

    ;; Just one sink.
  (int<nub>:output:sink level sinks msg args)))


(defun int<nub>:output:sink (level sink msg args)
  "Output MSG with ARGS to the one SINK."
  ;; If we should use the default/fallback sink, grab that first.
  (when (or (eq sink int<nub>:var:user:fallback)
            (eq sink t))
    (setq sink (int<nub>:var:sink int<nub>:var:user:fallback level)))

  ;;------------------------------
  ;; Output to sink.
  ;;------------------------------
  ;; Do not output at all.
  (cond ((eq sink nil)
         nil)

        ;; Output to the sink function.
        ((functionp sink)
         (apply sink msg args))

        ;; Anything else is an error.
        (t
         (int<nub>:error "int<nub>:output:sink"
                         '(:newlines
                           "Unknown sink? %S"
                           "Output Message:"
                           "───────────────"
                           "%s")
                         sink
                         (apply #'format msg args)))))


(defun int<nub>:output:message (user level msg args)
  "Decides how to output LEVEL keyword (`int<nub>:output:enabled?') MSG and
ARGS based on current verbosity for the level."
  (let ((func.name "int<nub>:output:message"))
    (int<nub>:user:exists? func.name user :error)

    (let ((sinks           (int<nub>:var:sink     user level int<nub>:var:user:fallback))
          (verbosity:level (int<nub>:var:enabled? user level int<nub>:var:user:fallback)))
      ;; Should complain about invalid sink function(s).
      (int<nub>:var:sink:verify func.name
                                sinks
                                :error)

      ;; Output message depending on LEVEL's current verbosity.
      (cond
       ;;------------------------------
       ;; Valid Values
       ;;------------------------------
       ;;---
       ;; Normal on/off
       ;;---
       ((eq verbosity:level t)
        ;; Do the normal/default thing.
        (int<nub>:output:sinks level sinks msg args))

       ((eq verbosity:level nil)
        ;; Do nothing
        nil)

       ;;---
       ;; Solo Function
       ;;---
       ;; Use the specified function.
       ((functionp verbosity:level)
        ;; Ask user if this level should be enabled (give default for level in case they want that).
        (when (funcall verbosity:level level (int<nub>:var:enabled? int<nub>:var:user:fallback level))
          ;; The user's predicate says the level is enabled; output.
          (int<nub>:output:sinks level sinks msg args)))

       ;;------------------------------
       ;; Errors/Invalids
       ;;------------------------------
       (t
        ;; Don't know what to do with verbosity's value.
        (int<nub>:error func.name
                        '("Verbosity for user '%S' at level '%S' is '%S', "
                          "and we don't know what to do with that.\n"
                          "Output Message:\n"
                          "───────────────\n"
                          "%s")
                        user
                        level
                        verbosity:level
                        (apply #'format msg args)))))))


(defun int<nub>:output:format (caller user level &rest message-format)
  "Combines CALLER and USER's MESSAGE-FORMAT into one string for sending to
the user's output function(s) with MESSAGE-FORMAT's args.

NOTE: Is just for the formatting /message/. Args should be passed to `error', `warn',
etc. Or, best: use `int<nub>:output' for a higher-level API.

Proper use:
  (int<nub>:output :error
                   \"example-function\"
                   '(\"Imagine this '%s' is a long \"
                     \"error string: %S %d\")
                   some-string something some-integer)
    -> \"[ERROR] 'examples error prefix here': example-function: <...>\"

Alternative/direct use:
  (error (int<nub>:output:format
          \"example-function\"
          :example-user
          :error
          \"Imagine this '%s' is a long \"
          \"error string: %S %d\")
          some-string something some-integer)
    -> \"[ERROR] 'examples error prefix here': example-function: <...>\""
  (int<nub>:user:exists? "int<nub>:output:format" user :error)

  (apply #'concat
         (int<nub>:var:prefix user level)
         caller
         ": "
         message-format))


;;------------------------------------------------------------------------------
;; Output API - Errors, Warnings, etc
;;------------------------------------------------------------------------------

(defun nub:output (user level caller formatting &rest args)
  "Format to standard message output for the USER with CALLER info, then output
the message with FORMATTING and ARGS to the correct place according to LEVEL's
current verbosity (e.g. #'error for `:error' verbosity normally).

For valid levels, see `nub:output:levels' keywords.

Uses FORMATTING string/list-of-strings with `int<nub>:output:format' to create
the message format, then applies that format plus any ARGS to the `error'
signaled."
  ;; Try to be real forgiving about what params are since we're erroring...
  ;; ...but also try to let them know they did something wrong so it can be fixed.

  (let ((func.name "nub:output"))
    ;;------------------------------
    ;; Validate Inputs
    ;;------------------------------
    (int<nub>:user:exists? func.name user :error)

    (unless (stringp caller)
      (int<nub>:output:message
       user
       :warn
       "%s: Invalid CALLER parameter! Should be a string, got: type: %S, value: %S, stringp?: %S"
       func.name
       (list (type-of caller)
             caller
             (stringp caller))))

    (unless (or (stringp formatting) (listp formatting))
      (int<nub>:output:message
       user
       :warn
       "%s: invalid FORMATTING parameter! Should be a list or a string, got: type: %S, value: %S, string/list?: %S"
       func.name
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
      (int<nub>:output:message user
                               level
                               (apply #'int<nub>:output:format user level caller formatting)
                               args))

     ((stringp formatting)
      (int<nub>:output:message user
                               level
                               (int<nub>:output:format caller user level formatting)
                               args))

     ;;---
     ;; Invalid formatting.
     ;;---
     ;; Do your best to get something.
     (t
      (int<nub>:output:message
       user
       :error
       (int<nub>:output:format
        caller
        user
        level
        (format "%s: Invalid FORMATTING - expected list or strig. formatting: '%S', args: '%S'"
                func.name formatting args)))

      ;; Don't return `int<nub>:output:message' output.
      ;; Unit tests will disable error signaling sometimes so it's best if this returns nil.
      nil))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub 'output)
