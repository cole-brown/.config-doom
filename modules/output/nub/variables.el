;;; output/nub/variables.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                               Variables                                ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                 Things change; variables stay the same...                  ;;
;;                                 ──────────                                 ;;


(imp:require :nub 'alist)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst int<nub>:var:user:fallback :fallback
  "Fallback user - used when actual user not found so that output
can still happen.")


(defconst nub:output:levels  '(:error :warn :debug)
  "All of nub's output levels.")


;;------------------------------------------------------------------------------
;; Users
;;------------------------------------------------------------------------------

(defvar int<nub>:var:users nil
  "List of all users.")


(defun int<nub>:user:exists? (caller user &optional error?)
  "Returns non-nil if USER is a registered `nub' user."
  (if (memq user int<nub>:var:users)
      t
    (if error?
        (error "%s: User %S is not a register `nub' user!"
               caller
               user)
      nil)))


(defun int<nub>:init:user (user)
  "Adds USER as a registered `nub' user."
  (push user int<nub>:var:users))


;;------------------------------------------------------------------------------
;; Get from Alist for User at Level
;;------------------------------------------------------------------------------

(defun int<nub>:var:user-at-level (user level alist &optional default)
  "Get value from ALIST for USER at output LEVEL.

Returns DEFAULT if not found."
  (int<nub>:user:exists? "int<nub>:var:user-at-level" user :error)
  (if (not (int<nub>:alist:alist? alist))
      (error "ALIST must be an alist! Got: %S" alist)
    (int<nub>:alist:get/value level
                              (int<nub>:alist:get/value user alist)
                              default)))
;; (int<nub>:var:user-at-level :jeff :dne nil :does-not-exist)


;;------------------------------------------------------------------------------
;; Verbosity Settings
;;------------------------------------------------------------------------------
;; This allows our tests to take over output easier.
;;------------------------------

;;------------------------------
;; Output Message Prefixes
;;------------------------------

(defvar int<nub>:var:prefix:backup
  (list (cons int<nub>:var:user:fallback '((:error . "[ERROR   ]: ")
                                       (:warn  . "[WARN    ]: ")
                                       ;; Noticibly different so when debugging any error/warning messages stand out if all sent to the same buffer?
                                       (:debug . "[   debug]: "))))
  "Alist of USER keyword to alist of verbosity level to prefixes for output messages.")


(defvar int<nub>:var:prefix
  (int<nub>:alist:copy/shallow int<nub>:var:prefix:backup)
  "Alist of USER keyword to alist of verbosity level to prefixes for output messages.")


(defun int<nub>:var:prefix (user level)
  "Get message prefix for USER at output LEVEL."
  (int<nub>:user:exists? "int<nub>:var:prefix" user :error)
  (int<nub>:var:user-at-level user level int<nub>:var:prefix))
;; (int<nub>:var:prefix :fallback :debug)


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
     int<nub>:var:prefix:backup))

  ;; Set in the actual variable.
  (int<nub>:alist:update
   user
   alist
   int<nub>:var:prefix))
;; (int<nub>:init:prefix :test '((:error . "erm... uh-oh:")))


;;------------------------------
;; Verbosity Enabled? (Per-Level)
;;------------------------------

(defvar int<nub>:var:enabled?:backup
  (list (cons int<nub>:var:user:fallback '((:error . t)
                                       (:warn  . t)
                                       (:debug . t))))
  "Alist of USER keyword to verbosity of various log levels for the user.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defvar int<nub>:var:enabled?
  (int<nub>:alist:copy/shallow int<nub>:var:enabled?:backup)
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
     int<nub>:var:enabled?:backup))

  ;; Set in the actual variable.
  (int<nub>:alist:update
   user
   alist
   int<nub>:var:enabled?))
;; (int<nub>:init:enabled? :test '((:error . t)))


(defun int<nub>:var:enabled? (user level &optional default)
  "Get message prefix for USER at output LEVEL.

Returns DEFAULT if not found."
  (int<nub>:user:exists? "int<nub>:var:enabled?" user :error)

  (int<nub>:var:user-at-level user level int<nub>:var:enabled? default))
;; (int<nub>:var:enabled? :test :error)


(defun int<nub>:var:enabled?:set (user level value)
  "Set message prefix for USER at output LEVEL."
  (int<nub>:user:exists? "int<nub>:var:enabled?:set" user :error)

  (let* ((alist/user (int<nub>:alist:get/value user int<nub>:var:enabled?))
         (alist/updated (int<nub>:alist:update level
                                               value
                                               alist/user)))
    (int<nub>:alist:update user
                           alist/updated
                           int<nub>:var:enabled?)))
;; (int<nub>:var:enabled?:set :test :debug 'foo)
;; (int<nub>:var:enabled?:set :test :warn 'bar)


;;------------------------------
;; Message Sinks (Per-Level)
;;------------------------------

(defconst int<nub>:var:sink:backup
  (list (cons int<nub>:var:user:fallback '((:error . error)
                                       (:warn  . warn)
                                       (:debug . message))))
  "Alist of USER keyword to an alist of output level keyword to sink value.

Valid values:
  t   - output normally
  nil - do not output
  <function> - Use <function> to output instead.
    - Used by unit testing.")


(defvar int<nub>:var:sink
  (int<nub>:alist:copy/shallow int<nub>:var:sink:backup)
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
     int<nub>:var:sink:backup))

  ;; Set in the actual variable.
  (int<nub>:alist:update
   user
   alist
   int<nub>:var:sink))
;; (int<nub>:init:sink :test '((:error . message)))


(defun int<nub>:var:sink (user level &optional default)
  "Get message prefix for USER at output LEVEL.

Returns DEFAULT if not found."
  (int<nub>:user:exists? "int<nub>:var:sink" user :error)

  (int<nub>:var:user-at-level user level int<nub>:var:sink default))
;; (int<nub>:var:sink :test :error)


(defun int<nub>:var:sink:set (user level value)
  "Set message prefix for USER at output LEVEL."
  (int<nub>:user:exists? "int<nub>:var:sink:set" user :error)

  (let* ((alist/user (int<nub>:alist:get/value user int<nub>:var:sink))
         (alist/updated (int<nub>:alist:update level
                                               value
                                               alist/user)))
    (int<nub>:alist:update user
                           alist/updated
                           int<nub>:var:sink)))
;; (int<nub>:var:sink:set :test :debug 'ignore)
;; (int<nub>:var:sink:set :test :warn 'warn)


;;------------------------------------------------------------------------------
;; Init/Reset all user's vars.
;;------------------------------------------------------------------------------

;; TODO: public init - just change this to `nub:init'?
(defun int<nub>:var:init (user &optional alist:enabled? alist:sinks alist:prefixes)
  "Registers USER and sets their default settings for output levels.

ALIST:ENABLED? should be an alist of verbosity level to t/nil.

ALIST:SINKS should be an alist of verbosity level to t/nil/function/list-of-functions.

ALIST:PREFIXES should be an alist of verbosity level to strings.

Alists should have all output levels in them; for valid levels, see
`nub:output:levels'.
If an alist is nil, the default/fallback will be used instead.

Sets both current and backup values (backups generally only used for tests)."
  (int<nub>:init:user     user)
  (when alist:enabled?
    (int<nub>:init:enabled? user alist:enabled?))
  (when alist:sinks
    (int<nub>:init:sink     user alist:sinks))
  (when alist:prefixes
    (int<nub>:init:prefix   user alist:prefixes)))


(defun int<nub>:var:reset (user)
  "Reset output vars for USER to their initialized/backup values."
  (int<nub>:user:exists? "int<nub>:var:reset" user :error)

  (let ((default:enabled? (int<nub>:alist:get/value user int<nub>:var:enabled?:backup))
        (default:sink     (int<nub>:alist:get/value user int<nub>:var:sink:backup))
        (default:prefix   (int<nub>:alist:get/value user int<nub>:var:prefix:backup)))
    (if default:enabled?
        (int<nub>:alist:update user
                               default:enabled?
                               int<nub>:var:enabled?)
      (int<nub>:alist:delete user
                             int<nub>:var:enabled?))

    (if default:sink
        (int<nub>:alist:update user
                               default:sink
                               int<nub>:var:sink)
      (int<nub>:alist:delete user
                             int<nub>:var:sink))

    (if default:prefix
        (int<nub>:alist:update user
                               default:prefix
                               int<nub>:var:prefix)
      (int<nub>:alist:delete user
                             int<nub>:var:prefix))

  nil))
;; (setq int<nub>:var:enabled? nil)
;; (int<nub>:output:vars/reset :test)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub 'variables)
