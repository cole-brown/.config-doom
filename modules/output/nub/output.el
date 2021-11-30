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


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst int<nub>:user:fallback :fallback
  "Fallback user - used when actual user not found so that output
can still happen.")


(defconst nub:output:levels  '(:error :warn :debug)
  "All of nub's output levels.")


;;------------------------------------------------------------------------------
;; Get from Alist for User at Level
;;------------------------------------------------------------------------------

(defun int<nub>:output:for-user-at-level (user level alist)
  "Get value from ALIST for USER at output LEVEL."
  (if (not (int<nub>:alist:alist? alist))
      (error "ALIST must be an alist! Got: %S" alist)
    (int<nub>:alist:get/value level
                              (int<nub>:alist:get/value user alist))))


;;------------------------------------------------------------------------------
;; Output Message Prefixes
;;------------------------------------------------------------------------------

(defvar int<nub>:output:message/prefix
  (list (cons int<nub>:user:fallback '((:error . "[ERROR   ]: ")
                                       (:warn  . "[WARN    ]: ")
                                       ;; Noticibly different so when debugging any error/warning messages stand out if all sent to the same buffer?
                                       (:debug . "[   debug]: "))))
  "Alist of USER keyword to alist of verbosity level to prefixes for output messages.")


(defun int<nub>:output:message/prefix (user level)
  "Get message prefix for USER at output LEVEL."
  (int<nub>:output:for-user-at-level user level int<nub>:output:message/prefix))
;; (int<nub>:output:message/prefix :fallback :debug)


;;------------------------------------------------------------------------------
;; Verbosity
;;------------------------------------------------------------------------------
;; This allows our tests to take over output easier.
;;------------------------------

(defvar int<nub>:backup:enabled?
  (list (cons int<nub>:user:fallback '((:error . t)
                                       (:warn  . t)
                                       (:debug . t))))
  "Alist of USER keyword to verbosity of various log levels for the user.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defun int<nub>:init:enabled? (user alist)
  "Set 'enabled?' ALIST for USER.

ALIST should have all output levels in it.

Sets both current and backup values (backups generally only used for tests)."
  ;; Set in the backup variable.
  ;; Use a copy so it doesn't get changed out from under us.
  (let ((alist/copy (int<nub>:alist:copy/shallow alist)))
    (int<keyboard>:alist:update
     user
     (int<keyboard>:alist:update level
                                 value
                                 alist/copy)
     int<nub>:output:enabled?))

  ;; Set in the actual variable.
  (int<keyboard>:alist:update
   user
   (int<keyboard>:alist:update level
                               value
                               alist)
   int<nub>:output:enabled?))
;; TODO: test?


(defvar int<nub>:output:enabled?
  (copy-alist int<nub>:backup:enabled?)
  "Verbosity of various log levels for the ':keyboard' module.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defun int<nub>:output:enabled? (user level)
  "Get message prefix for USER at output LEVEL."
  (int<nub>:output:for-user-at-level user level int<nub>:output:enabled?))
;; TODO: test?


(defun int<nub>:output:enabled?:set (user level value)
  "Set message prefix for USER at output LEVEL."
  (let ((alist (int<nub>:alist:get/value user alist)))
    (int<keyboard>:alist:update
     user
     (int<keyboard>:alist:update level
                                 value
                                 alist)
     int<nub>:output:enabled?)))
;; TODO: test?


;; TODO:
;; TODO: Left off here...
;; TODO:


(defconst int<nub>:backup:sink
  (list (cons int<nub>:user:fallback '((:error . error)
                                       (:warn  . warn)
                                       (:debug . message))))
  "Alist of USER keyword to an alist of output level keyword to sink value.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defvar int<nub>:output:sink
  (copy-alist int<nub>:backup:sink)
  "Default alist of user keyword to an alist of output level keyword to sink value.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defun int<nub>:output:vars/reset ()
  "Reset output vars to their default values."
  (setq int<nub>:output:enabled? (copy-alist int<nub>:backup:enabled?)
        int<nub>:output:sink (copy-alist int<nub>:backup:sink)))
;; (setq int<nub>:output:enabled? nil)
;; (int<nub>:output:vars/reset)


(defun int<nub>:output/message (level msg args)
  "Decides how to output LEVEL keyword (`int<nub>:output:enabled?') MSG and
ARGS based on current verbosity for the level."
  (let ((func/default (alist-get level int<nub>:output:sink :does-not-exist))
        (verbosity    (alist-get level int<nub>:output:enabled? :does-not-exist)))
    ;; Should complain about no default.
    (when (eq func/default :does-not-exist)
      (error (concat "int<nub>:output:output: "
                     "Verbosity for '%S' is '%S', and we don't have a default output function in %S for that. "
                     "Output Message:\n%s")
             level
             unknown-value
             'int<nub>:output:sink
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
       ;; Didn't find LEVEL in `int<nub>:output:enabled?'.
       (error (concat "int<nub>:output:output: "
                      "Ouput function for verbosity level doesn't exist; don't know how to output message.\n"
                      "  verbosity level:    %S\n"
                      "  '%S' func:      %S\n"
                      "  existing 'verbose': %S\n"
                      "  existing 'default': %S\n"
                      "  message: %s")
              level
              level
              verbosity
              int<nub>:output:enabled?
              int<nub>:output:sink
              (apply #'format msg args)))

      (unknown-value
       ;; Found LEVEL, but don't know what to do with its value.
       (error (concat "int<nub>:output:output: "
                      "Verbosity for '%S' is '%S', and we don't know what to do with that. "
                      "Output Message:\n%s")
              level
              unknown-value
              (apply #'format msg args))))))


;;------------------------------------------------------------------------------
;; Output API - Errors, Warnings, etc
;;------------------------------------------------------------------------------

(defun int<nub>:output:format (level caller &rest message-format)
  "Combines CALLER and error MESSAGE-FORMAT into one string for sending to
`error' with MESSAGE-FORMAT's args.

NOTE: Is just for the formatting /message/. Args should be passed to `error', `warn',
etc. Or, best: use `int<nub>:output'.

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
  (apply #'concat
         (alist-get level int<nub>:output:message/prefix)
         caller
         ": "
         message-format))


(defun int<nub>:output (level caller formatting &rest args)
  "Format to standard message output for the USER with CALLER info, then output
the message with FORMATTING and ARGS to the correct place according to LEVEL's
current verbosity (e.g. #'error for `:error' verbosity normally).

For valid LEVELs, see `int<nub>:output:enabled?' keywords.

Uses FORMATTING string/list-of-strings with `int<nub>:output:format' to create
the message format, then applies that format plus any ARGS to the `error'
signaled."
  ;; Try to be real forgiving about what params are since we're erroring...
  ;; ...but also try to let them know they did something wrong so it can be fixed.

  ;;------------------------------
  ;; Validate Inputs
  ;;------------------------------
  (unless (stringp caller)
    (int<nub>:output/message
     :warn
     "int<nub>:output: invalid CALLER parameter! Should be a string, got: type: %S, value: %S, stringp?: %S"
     (list (type-of caller)
           caller
           (stringp caller))))
  (unless (or (stringp formatting) (listp formatting))
    (int<nub>:output/message
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
    (int<nub>:output/message level
                             (apply #'int<nub>:output:format level caller formatting)
                             args))

   ((stringp formatting)
    (int<nub>:output/message level
                             (int<nub>:output:format level caller formatting)
                             args))

   ;;---
   ;; Invalid formatting.
   ;;---
   ;; Do your best to get something.
   (t
    (int<nub>:output/message
     :error
     (int<nub>:output:format
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
