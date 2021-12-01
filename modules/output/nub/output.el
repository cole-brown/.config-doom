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
;; Constants
;;------------------------------------------------------------------------------

(defconst int<nub>:user:fallback :fallback
  "Fallback user - used when actual user not found so that output
can still happen.")


(defconst nub:output:levels  '(:error :warn :debug)
  "All of nub's output levels.")


;;------------------------------------------------------------------------------
;; Users
;;------------------------------------------------------------------------------

(defvar int<nub>:users nil
  "List of all users.")


(defun int<nub>:user:exists? (caller user &optional error?)
  "Returns non-nil if USER is a registered `nub' user."
  (if (memq user int<nub>:users)
      t
    (if error?
        (error "%s: User %S is not a register `nub' user!"
               caller
               user)
      nil)))


(defun int<nub>:init:user (user)
  "Adds USER as a registered `nub' user."
  (push user int<nub>:users))


;;------------------------------------------------------------------------------
;; Get from Alist for User at Level
;;------------------------------------------------------------------------------

(defun int<nub>:output:user-at-level (user level alist &optional default)
  "Get value from ALIST for USER at output LEVEL.

Returns DEFAULT if not found."
  (int<nub>:user:exists? "int<nub>:output:user-at-level" user :error)
  (if (not (int<nub>:alist:alist? alist))
      (error "ALIST must be an alist! Got: %S" alist)
    (int<nub>:alist:get/value level
                              (int<nub>:alist:get/value user alist)
                              default)))
;; (int<nub>:output:user-at-level :jeff :dne nil :does-not-exist)


;;------------------------------------------------------------------------------
;; Verbosity Settings
;;------------------------------------------------------------------------------
;; This allows our tests to take over output easier.
;;------------------------------

;;------------------------------
;; Output Message Prefixes
;;------------------------------

(defvar int<nub>:backup:prefix
  (list (cons int<nub>:user:fallback '((:error . "[ERROR   ]: ")
                                       (:warn  . "[WARN    ]: ")
                                       ;; Noticibly different so when debugging any error/warning messages stand out if all sent to the same buffer?
                                       (:debug . "[   debug]: "))))
  "Alist of USER keyword to alist of verbosity level to prefixes for output messages.")


(defvar int<nub>:output:prefix
  (int<nub>:alist:copy/shallow int<nub>:backup:prefix)
  "Alist of USER keyword to alist of verbosity level to prefixes for output messages.")


(defun int<nub>:output:prefix (user level)
  "Get message prefix for USER at output LEVEL."
  (int<nub>:user:exists? "int<nub>:output:prefix" user :error)
  (int<nub>:output:user-at-level user level int<nub>:output:prefix))
;; (int<nub>:output:prefix :fallback :debug)


(defun int<nub>:init:prefix (user alist)
  "Set output message prefix string ALIST for USER.

ALIST should have all output levels in it.

Sets both current and backup values (backups generally only used for tests)."
  (int<nub>:user:exists? "int<nub>:init:prefix" user :error)
  ;; Set in the backup variable.
  ;; Use a copy so it doesn't get changed out from under us.
  (let ((alist/copy (int<nub>:alist:copy/shallow alist)))
    (int<nub>:alist:update
     user
     alist/copy
     int<nub>:backup:prefix))

  ;; Set in the actual variable.
  (int<nub>:alist:update
   user
   alist
   int<nub>:output:prefix))
;; (int<nub>:init:prefix :test '((:error . "erm... uh-oh:")))


;;------------------------------
;; Verbosity Enabled? (Per-Level)
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


(defvar int<nub>:output:enabled?
  (int<nub>:alist:copy/shallow int<nub>:backup:enabled?)
  "Default alist of USER keyword to verbosity of various log levels for the user.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defun int<nub>:init:enabled? (user alist)
  "Set 'enabled?' ALIST for USER.

ALIST should have all output levels in it.

Sets both current and backup values (backups generally only used for tests)."
  (int<nub>:user:exists? "int<nub>:init:enabled?" user :error)

  ;; Set in the backup variable.
  ;; Use a copy so it doesn't get changed out from under us.
  (let ((alist/copy (int<nub>:alist:copy/shallow alist)))
    (int<nub>:alist:update
     user
     alist/copy
     int<nub>:backup:enabled?))

  ;; Set in the actual variable.
  (int<nub>:alist:update
   user
   alist
   int<nub>:output:enabled?))
;; (int<nub>:init:enabled? :test '((:error . t)))


(defun int<nub>:output:enabled? (user level &optional default)
  "Get message prefix for USER at output LEVEL.

Returns DEFAULT if not found."
  (int<nub>:user:exists? "int<nub>:output:enabled?" user :error)

  (int<nub>:output:user-at-level user level int<nub>:output:enabled? default))
;; (int<nub>:output:enabled? :test :error)


(defun int<nub>:output:enabled?:set (user level value)
  "Set message prefix for USER at output LEVEL."
  (int<nub>:user:exists? "int<nub>:output:enabled?:set" user :error)

  (let* ((alist/user (int<nub>:alist:get/value user int<nub>:output:enabled?))
         (alist/updated (int<nub>:alist:update level
                                               value
                                               alist/user)))
    (int<nub>:alist:update user
                           alist/updated
                           int<nub>:output:enabled?)))
;; (int<nub>:output:enabled?:set :test :debug 'foo)
;; (int<nub>:output:enabled?:set :test :warn 'bar)


;;------------------------------
;; Message Sinks (Per-Level)
;;------------------------------

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
  (int<nub>:alist:copy/shallow int<nub>:backup:sink)
  "Default alist of user keyword to an alist of output level keyword to sink value.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defun int<nub>:init:sink (user alist)
  "Set 'sink' ALIST for USER.

ALIST should have all output levels in it.

Sets both current and backup values (backups generally only used for tests)."
  (int<nub>:user:exists? "int<nub>:init:sink" user :error)

  ;; Set in the backup variable.
  ;; Use a copy so it doesn't get changed out from under us.
  (let ((alist/copy (int<nub>:alist:copy/shallow alist)))
    (int<nub>:alist:update
     user
     alist/copy
     int<nub>:backup:sink))

  ;; Set in the actual variable.
  (int<nub>:alist:update
   user
   alist
   int<nub>:output:sink))
;; (int<nub>:init:sink :test '((:error . message)))


(defun int<nub>:output:sink (user level &optional default)
  "Get message prefix for USER at output LEVEL.

Returns DEFAULT if not found."
  (int<nub>:user:exists? "int<nub>:output:sink" user :error)

  (int<nub>:output:user-at-level user level int<nub>:output:sink default))
;; (int<nub>:output:sink :test :error)


(defun int<nub>:output:sink:set (user level value)
  "Set message prefix for USER at output LEVEL."
  (int<nub>:user:exists? "int<nub>:output:sink:set" user :error)

  (let* ((alist/user (int<nub>:alist:get/value user int<nub>:output:sink))
         (alist/updated (int<nub>:alist:update level
                                               value
                                               alist/user)))
    (int<nub>:alist:update user
                           alist/updated
                           int<nub>:output:sink)))
;; (int<nub>:output:sink:set :test :debug 'ignore)
;; (int<nub>:output:sink:set :test :warn 'warn)


;;------------------------------------------------------------------------------
;; Init/Reset all user's vars.
;;------------------------------------------------------------------------------

(defun int<nub>:var:init (user alist:enabled? alist:sinks alist:prefixes)
  "Set 'sink' ALIST for USER.

ALIST should have all output levels in it.

Sets both current and backup values (backups generally only used for tests)."
  (int<nub>:init:user     user)
  (int<nub>:init:enabled? user alist:enabled?)
  (int<nub>:init:sink     user alist:sinks)
  (int<nub>:init:prefix   user alist:prefixes))


(defun int<nub>:var:reset (user)
  "Reset output vars for USER to their default values."
  (int<nub>:user:exists? "int<nub>:var:reset" user :error)

  (let ((default:enabled? (int<nub>:alist:get/value user int<nub>:backup:enabled?))
        (default:sink     (int<nub>:alist:get/value user int<nub>:backup:sink))
        (default:prefix   (int<nub>:alist:get/value user int<nub>:backup:sink)))
    (if default:enabled?
        (int<nub>:alist:update user
                               default:enabled?
                               int<nub>:output:enabled?)
      (int<nub>:alist:delete user
                             int<nub>:output:enabled?))

    (if default:sink
        (int<nub>:alist:update user
                               default:sink
                               int<nub>:output:sink)
      (int<nub>:alist:delete user
                             int<nub>:output:sink))

    (if default:prefix
        (int<nub>:alist:update user
                               default:prefix
                               int<nub>:output:prefix)
      (int<nub>:alist:delete user
                             int<nub>:output:prefix))

  nil))
;; (setq int<nub>:output:enabled? nil)
;; (int<nub>:output:vars/reset :test)


;;------------------------------------------------------------------------------
;; Output Message Helpers
;;------------------------------------------------------------------------------

(defun int<nub>:output/message (user level msg args)
  "Decides how to output LEVEL keyword (`int<nub>:output:enabled?') MSG and
ARGS based on current verbosity for the level."
  (int<nub>:user:exists? "int<nub>:output/message" user :error)

  (let ((sink:function   (int<nub>:output:sink     user level :does-not-exist))
        (verbosity:level (int<nub>:output:enabled? user level :does-not-exist)))
    ;; Should complain about no default.
    (when (eq sink:function :does-not-exist)
      (error (concat "int<nub>:output:output: "
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
       ;; Didn't find LEVEL in `int<nub>:output:enabled?'.
       (error (concat "int<nub>:output:output: "
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
              int<nub>:output:enabled?
              int<nub>:output:sink
              (apply #'format msg args)))

      (unknown-value
       ;; Found LEVEL, but don't know what to do with its value.
       (error (concat "int<nub>:output:output: "
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
         (int<nub>:output:prefix user level)
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

For valid LEVELs, see `int<nub>:output:enabled?' keywords.

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
