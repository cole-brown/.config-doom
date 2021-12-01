;;; output/nub/base.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Error/Warn/Etc.                             ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                  Delete if you can make error-proof code.                  ;;
;;                                 ──────────                                 ;;

(require 'seq)
(imp:require :nub 'alist)


;; TODO: Change to `int<nub>:var...'?


;;------------------------------------------------------------------------------
;; Output Message Helpers
;;------------------------------------------------------------------------------

(defun int<nub>:output/message (user level msg args)
  "Decides how to output LEVEL keyword (`int<nub>:output:enabled?') MSG and
ARGS based on current verbosity for the level."
  (int<nub>:user:exists? "int<nub>:output/message" user :error)

  (let ((sink:function   (int<nub>:var:sink     user level :does-not-exist))
        (verbosity:level (int<nub>:var:enabled? user level :does-not-exist)))
    ;; Should complain about no default.
    (when (eq sink:function :does-not-exist)
      (error (concat "int<nub>:output/message: "
                     "No output function for user %S at level %S! "
                     "Output Message:\n%s")
             user
             level
             (apply #'format msg args)))

    ;; Output message depending on LEVEL's current verbosity.
    (pcase verbosity:level
      ;;------------------------------
      ;; Valid Values
      ;;------------------------------
      ;;---
      ;; Normal on/off
      ;;---
      ('t
       ;; Do the normal/default thing.
       (apply sink:function msg args))

      ('nil
       ;; Do nothing
       nil)

      ;;---
      ;; List (of Functions/t (for Debugging?))
      ;;---
      ;; Use several specified function.
      ((and (pred listp)
            (pred (lambda (verbose) (seq-reduce (lambda (reduction element)
                                             "Allow either functions to call or `t' for 'call the default thing too'."
                                             (and reduction
                                                  (or (functionp element) (eq element t))))
                                           verbose
                                           #'identity))))
       (dolist (func verbosity:level)
         (if (eq func t)
             ;; Do the default thing.
             (apply sink:function msg args)
           ;; Call the specified function.
           (apply func msg args))))

      ;;---
      ;; Solo Function
      ;;---
      ;; Use the specified function.
      ((pred functionp)
       (apply verbosity:level msg args))

      ;;------------------------------
      ;; Errors/Invalids
      ;;------------------------------
      (:does-not-exist
       ;; Didn't find LEVEL in `int<nub>:var:enabled?'.
       (error (concat "int<nub>:var:output: "
                      "Ouput function for verbosity level doesn't exist; don't know how to output message.\n"
                      "  user:               %S\n"
                      "  verbosity level:    %S\n"
                      "  '%S' func:      %S\n"
                      "  existing 'verbose': %S\n"
                      "  existing 'default': %S\n"
                      "  message: %s")
              user
              level
              level verbosity:level
              int<nub>:var:enabled?
              int<nub>:var:sink
              (apply #'format msg args)))

      (unknown-value
       ;; Found LEVEL, but don't know what to do with its value.
       (error (concat "int<nub>:var:output: "
                      "Verbosity for user '%S' at level '%S' is '%S', and we don't know what to do with that. "
                      "Output Message:\n%s")
              user
              level
              unknown-value
              (apply #'format msg args))))))


(defun int<nub>:output:format (user level caller &rest message-format)
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

(defun int<nub>:output (user level caller formatting &rest args)
  "Format to standard message output for the USER with CALLER info, then output
the message with FORMATTING and ARGS to the correct place according to LEVEL's
current verbosity (e.g. #'error for `:error' verbosity normally).

For valid levels, see `nub:output:levels' keywords.

Uses FORMATTING string/list-of-strings with `int<nub>:output:format' to create
the message format, then applies that format plus any ARGS to the `error'
signaled."
  ;; Try to be real forgiving about what params are since we're erroring...
  ;; ...but also try to let them know they did something wrong so it can be fixed.

  ;;------------------------------
  ;; Validate Inputs
  ;;------------------------------
  (int<nub>:user:exists? "int<nub>:output" user :error)

  (unless (stringp caller)
    (int<nub>:output/message
     user
     :warn
     "int<nub>:output: invalid CALLER parameter! Should be a string, got: type: %S, value: %S, stringp?: %S"
     (list (type-of caller)
           caller
           (stringp caller))))

  (unless (or (stringp formatting) (listp formatting))
    (int<nub>:output/message
     user
     :warn
     "int<nub>:output: invalid FORMATTING parameter! Should be a list or a string, got: type: %S, value: %S, string/list?: %S"
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
    (int<nub>:output/message user
                             level
                             (apply #'int<nub>:output:format level caller formatting)
                             args))

   ((stringp formatting)
    (int<nub>:output/message user
                             level
                             (int<nub>:output:format level caller formatting)
                             args))

   ;;---
   ;; Invalid formatting.
   ;;---
   ;; Do your best to get something.
   (t
    (int<nub>:output/message
     user
     :error
     (int<nub>:output:format
      user
      level
      caller
      (format "Invalid FORMATTING - expected list or strig. formatting: '%S', args: '%S'"
              formatting args)))

    ;; Don't return `int<nub>:output/message' output.
    ;; Unit tests will disable error signaling sometimes so it's best if this returns nil.
    nil)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub 'output)
