;;; output/nub/variables.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                               Variables                                ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                 Things change; variables stay the same...                  ;;
;;                                 ──────────                                 ;;


(imp:require :nub 'internal)
(imp:require :nub 'alist)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst int<nub>:var:user:fallback :default
  "Fallback user - used when actual user not found so that output
can still happen.")


(defconst nub:output:levels  '(:error :warn :info :debug)
  "All of nub's output levels.")


(defun int<nub>:level:exists? (caller level &optional error?)
  "Returns non-nil if level is a valid `nub' output level."
  (if (memq level nub:output:levels)
      level

    (if error?
        (int<nub>:error caller
                        "Level %S is not a valid `nub' output level!"
                        level)
      nil)))


;;------------------------------------------------------------------------------
;; Users
;;------------------------------------------------------------------------------

(defvar int<nub>:var:users nil
  "List of all users.")


(defun int<nub>:user:exists? (caller user &optional error?)
  "Returns non-nil if USER is a registered `nub' user."
  (if (or (eq user int<nub>:var:user:fallback)
          (memq user int<nub>:var:users))
      t

    (if error?
        (int<nub>:error caller
                        "User %S is not a register `nub' user!"
                        user)
      nil)))


(defun int<nub>:init:user (user)
  "Adds USER as a registered `nub' user."
  (push user int<nub>:var:users))


(defun int<nub>:terminate:user (user)
  "Adds USER as a registered `nub' user."
  (setq int<nub>:var:users (remove user int<nub>:var:users)))


;;------------------------------------------------------------------------------
;; Get from Alist for User at Level
;;------------------------------------------------------------------------------

(defun int<nub>:var:assert-user-level (caller user level error?)
  "Assert that USER is registered and LEVEL is a valid `nub' output level.

If ERROR? is non-nil, signals an error if things are not ok.
Else returns nil if things are not ok."
  (and (int<nub>:user:exists?  caller user  error?)
       (int<nub>:level:exists? caller level error?)))


(defun int<nub>:var:user-at-level (user level alist &optional default)
  "Get value from ALIST for USER at output LEVEL.

Returns DEFAULT if not found.
  - If DEFAULT is `int<nub>:var:user:fallback', returns the value for that
    user at LEVEL from ALIST."
  ;; Ensure USER and LEVEL are ok.
  (int<nub>:var:assert-user-level "int<nub>:var:user-at-level" user level :error)

  ;; Assert ALIST.
  (if (not (int<nub>:alist:alist? alist))
      (int<nub>:error "int<nub>:var:user-at-level"
                      "ALIST must be an alist! Got: %S"
                      alist)
    ;; Try to get the value for USER at LEVEL - we'll fall back if they've requested it.
    (let ((value (int<nub>:alist:get/value level
                                           (int<nub>:alist:get/value user alist)
                                           default)))
      ;; Do we need to get the fallback/default value?
      (when (and (eq default int<nub>:var:user:fallback)
                 (eq value default))
        (setq value (int<nub>:alist:get/value level
                                              (int<nub>:alist:get/value int<nub>:var:user:fallback alist)
                                              :does-not-exist))
        ;; If it's still not found then we should error on the level, probably?
        (when (eq value :does-not-exist)
          (int<nub>:error "int<nub>:var:user-at-level"
                          "User %S at level %S had no value and no fallback/default. Invalid level?"
                          user level)))

      ;; Done; return the value.
      value)))
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
                                           (:info  . "[INFO    ]: ")
                                           ;; Noticibly different so when debugging any error/warning messages stand out if all sent to the same buffer?
                                           (:debug . "[   debug]: "))))
  "Alist of USER keyword to alist of verbosity level to prefixes for output messages.")


(defvar int<nub>:var:prefix
  (int<nub>:alist:copy/shallow int<nub>:var:prefix:backup)
  "Alist of USER keyword to alist of verbosity level to prefixes for output messages.")


(defun int<nub>:var:prefix (user level)
  "Get message prefix for USER at output LEVEL."
  ;; Ensure USER and LEVEL are ok.
  (int<nub>:var:assert-user-level "int<nub>:var:prefix" user level :error)

  (int<nub>:var:user-at-level user level int<nub>:var:prefix int<nub>:var:user:fallback))
;; (int<nub>:var:prefix :fallback :debug)


(defun int<nub>:init:prefix (user alist)
  "Set output message prefix string ALIST for USER.

ALIST should have all output levels in it.

Sets both current and backup values (backups generally only used for tests)."
  ;; Ensure USER is ok.
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
                                           (:info  . t)
                                           (:debug . t))))
  "Alist of USER keyword to verbosity of various log levels for the user.

Valid values:
  non-nil     - output normally
  nil         - do not output
  <predicate> - Call <predicate> (w/ LEVEL & DEFAULT) to get nil/non-nil value.

Predicate's signature should be:
  (defun enabled-predicate-for-my-user (level &optional default) ...)
    - It should return nil/non-nil.")


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
  ;; Ensure USER is ok.
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


(defun int<nub>:var:enabled? (user level &optional default)
  "Returns non-nil if output is enabled for USER at output LEVEL.

Returns DEFAULT if USER has no setting for LEVEL.
  - If DEFAULt is `:default', returns the standard/default/fallback for LEVEL."
  ;; Ensure USER and LEVEL are ok.
  (int<nub>:var:assert-user-level "int<nub>:var:enabled?" user level :error)

  (let ((enabled? (int<nub>:var:user-at-level user
                                              level
                                              int<nub>:var:enabled?
                                              default)))

    ;; User not found in `int<nub>:var:enabled?'? Use fallback.
    (cond ((and (eq default int<nub>:var:user:fallback)
                (eq enabled? default))
           ;; Didn't find it - get the fallback.
           (int<nub>:var:user-at-level int<nub>:var:user:fallback
                                       level
                                       int<nub>:var:enabled?
                                       default))

          ;; Found a function - call w/ level to get enabled value.
          ((functionp enabled?)
           (funcall enabled? level default))

          ;; Default: Found nil or non-nil - return that.
          (t
           enabled?))))
;; (int<nub>:var:enabled? :default :error)
;; (int<nub>:var:enabled? :test<nub/utils>::int<nub>:var:enabled? :info :default)


(defun int<nub>:var:enabled?:set (user level value)
  "Set message prefix for USER at output LEVEL."
  ;; Ensure USER and LEVEL are ok.
  (int<nub>:var:assert-user-level "int<nub>:var:enabled?:set" user level :error)

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

(defvar int<nub>:var:sink:backup
  (list (cons int<nub>:var:user:fallback '((:error . error)
                                           (:warn  . warn)
                                           (:info  . message)
                                           (:debug . message))))
  "Alist of USER keyword to an alist of output level keyword to sink function.")


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
  ;; Ensure USER is ok.
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
  "Returns non-nil if output is enabled for USER at output LEVEL.

Returns DEFAULT if USER has no setting for LEVEL.
  - If DEFAULt is `:default', returns the standard/default/fallback for LEVEL."
  ;; Ensure USER and LEVEL are ok.
  (int<nub>:var:assert-user-level "int<nub>:var:sink" user level :error)

  (let ((sink (int<nub>:var:user-at-level user
                                              level
                                              int<nub>:var:sink
                                              default)))
    (if (and (eq default int<nub>:var:user:fallback)
             (eq sink default))
        ;; Didn't find it - get the fallback.
        (int<nub>:var:user-at-level int<nub>:var:user:fallback
                                    level
                                    int<nub>:var:sink
                                    default)
      sink)))
;; (int<nub>:var:sink :test :error)


(defun int<nub>:var:sink:set (user level value)
  "Set message prefix for USER at output LEVEL."
  ;; Ensure USER and LEVEL are ok.
  (int<nub>:var:assert-user-level "int<nub>:var:sink:set" user level :error)

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
;; Debugging
;;------------------------------------------------------------------------------

(defvar int<nub>:var:debugging nil
  "Alist of USER keyword to boolean debug flag. Non-nil means debugging is active.")


(defun int<nub>:var:debugging (user &optional default)
  "Get debugging flag for USER.

Returns DEFAULT if not found."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debugging" user :error)

  (int<nub>:alist:get/value user
                            int<nub>:var:debugging
                            default))
;; (int<nub>:var:debugging :test)


(defun int<nub>:var:debugging:set (user value)
  "Set debugging flag for USER (or togggles the flag).

If VALUE is `:toggle', this will toggle the flag. Otherwise it will set/unset
the flag based on truthiness of VALUE."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debugging:set" user :error)

  (let* ((debugging? (int<nub>:var:debugging user))
         (debug-flag (cond ((eq :toggle value)
                            (not debugging?))
                           (value
                            t)
                           (t
                            nil))))

    (int<nub>:alist:update user
                           debug-flag
                           int<nub>:var:debugging)))
;; (int<nub>:var:debugging :test)


(defvar int<nub>:var:debug:tags nil
  "Alist of USER keyword to list of active debugging keyword tags. Any
keyword matched in the list will be printed out when debugging is active.

If there are no tags in the list, or the list is nil, everything
will be printed.")


(defun int<nub>:var:debug:tags (user &optional default)
  "Get current debug tags flag for USER.

Returns DEFAULT if not found."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debug:tags" user :error)

  (int<nub>:alist:get/value user
                            int<nub>:var:debug:tags
                            default))
;; (int<nub>:var:debug:tags :test)


(defun int<nub>:var:debug:tags:set (user tags)
  "Set list of all active TAGS for USER"
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debug:tags:set" user :error)

  (unless (listp tags)
    (int<nub>:error "int<nub>:var:debug:tags"
                    "Tags must be a list or nil; got: %S"
                    tags))

  (if (null tags)
      (int<nub>:alist:delete user
                             int<nub>:var:debug:tags)
    (int<nub>:alist:update user
                           tags
                           int<nub>:var:debug:tags)))
;; (int<nub>:var:debug:tags :test)


(defun int<nub>:var:debug:tag:active? (user tag)
  "Returns whether TAG is active for USER."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debug:tag:active?" user :error)

  (not (null (memq tag (int<nub>:var:debug:tags user)))))
;; (int<nub>:var:debug:tags :test)


(defun int<nub>:var:debug:tag:set (user tag value)
  "Sets USER's debug TAG to VALUE (or togggles the tag).

If VALUE is `:toggle', this will toggle TAG. Otherwise it will set/unset
TAG based on truthiness of VALUE."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debug:tag:set" user :error)

  (let ((action (if value
                    :add
                  :delete)))

    ;; Did they ask us to toggle it?
    (when (eq value :toggle)
      ;; Toggling, so get the value first.
      (let ((current (int<nub>:var:debug:tag:active? user tag)))
        ;; Update `value' so we can pretend they asked for the 'correct' value to do a toggle.
        ;;   - If it's currently set, delete it & vice versa.
        (setq action (if current
                         :delete
                       :add))))

    ;; Now we can just set to what `action' says.
    ;;   - If truthy, that means ensure tag is in list.
    ;;   - If falsy, that means delete tag from list.
    (cond ((eq action :add)
           (let ((tags (int<nub>:alist:get/value user
                                                 int<nub>:var:debug:tags)))
             (push tag tags)
             (int<nub>:alist:update user
                                    tags
                                    int<nub>:var:debug:tags))
           ;; Return truthy to indicate it was turned on.
           t)

          ((eq action :delete)
           (let* ((tags (int<nub>:alist:get/value user
                                                  int<nub>:var:debug:tags))
                  (tags:updated (remove tag tags)))
             (int<nub>:alist:update user
                                    tags:updated
                                    int<nub>:var:debug:tags))
           ;; Return falsy to indicate it was turned off.
           nil)

          (t
           (int<nub>:error "int<nub>:var:debug:tag:set"
                           "Don't know what to do? Action is: %S"
                           action)))))
;; (int<nub>:var:debug:tags :test)


(defvar int<nub>:var:debug:tags/common nil
  "Alist of USER keyword to list of common debugging keyword tags.

Used to prompt end-user in interactive commands.

Any keyword can be used regardless of this list - these will be provided to
`nub:debug/toggle-tag' as potential candidates to toggle.")


(defun int<nub>:var:debug:tags/common (user)
  "Get common debug tags flag for USER.

Returns `nil' if not found."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debug:tags/common" user :error)

  (int<nub>:alist:get/value user
                            int<nub>:var:debug:tags/common))
;; (int<nub>:var:debug:tags :test)


(defun int<nub>:var:debug:tags/common:set (user tags)
  "Sets USER's list of common debug TAGS."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debug:tags/common:set" user :error)

  (int<nub>:alist:update user
                         tags
                         int<nub>:var:debug:tags/common))
;; (int<nub>:var:debug:tags/common:set :test '(:hello :there))


;;------------------------------------------------------------------------------
;; Debug Message Helpers
;;------------------------------------------------------------------------------

(defconst int<nub>:var:debug:fills
  (list (cons int<nub>:var:user:fallback '("  "
                                           "- ")))
  "Alist of users to list of strings to use for alternating fill/padding strings.")


(defun int<nub>:var:debug:fills (user &optional default)
  "Get debug fill/padding strings for USER.

Returns DEFAULT if USER has no fill/padding strings.
  - If DEFAULt is `:default', returns the standard/default/fallback strings."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debug:fills" user :error)

  (let ((fills (int<nub>:alist:get/value user
                                         int<nub>:var:debug:fills)))
    (if (and (eq default int<nub>:var:user:fallback)
             (eq fills default))
        ;; Didn't find it - get the fallback.
        (int<nub>:alist:get/value int<nub>:var:user:fallback
                                  int<nub>:var:debug:fills)
      ;; Found it.
      fills)))
;; (int<nub>:var:debug:tags :test)


(defun int<nub>:var:debug:fills:set (user fill-strings)
  "Sets USER's list of fill/padding strings."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debug:fills:set" user :error)

  (int<nub>:alist:update user
                         fill-strings
                         int<nub>:var:debug:fills))
;; (int<nub>:var:debug:fills:set :test '("-.-" "^.^"))


(defvar int<nub>:var:debug:fills/index
  (list (cons int<nub>:var:user:fallback 0))
  "Alist of users to next fill/padding (index) to use from user's
`int<nub>:var:debug:fills' alist entry.")


(defun int<nub>:var:debug:fills/index (user &optional default)
  "Get current index into debug fill/padding strings for USER.

Returns DEFAULT if USER has no index.
  - If DEFAULt is `:default', returns the (shared)
    standard/default/fallback index."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debug:fills/index" user :error)

  (let ((fills/index (int<nub>:alist:get/value user
                                               int<nub>:var:debug:fills/index)))
    (if (and (eq default int<nub>:var:user:fallback)
             (eq fills/index default))
        ;; Didn't find it - get the fallback.
        (int<nub>:alist:get/value int<nub>:var:user:fallback
                                  int<nub>:var:debug:fills/index)
      ;; Found it.
      fills/index)))
;; (int<nub>:var:debug:tags :test)


(defun int<nub>:var:debug:fills/index:set (user index &optional create)
  "Sets USER's index into the list of fill/padding strings.

If CREATE is nil and USER doesn't exist in index alist, sets the
default user instead."
  ;; Ensure USER is ok.
  (int<nub>:user:exists? "int<nub>:var:debug:fills/index:set" user :error)

  (if (and (null create)
           (not (int<nub>:alist:get/pair user int<nub>:var:debug:fills/index)))
      ;; Updated default index instead.
      (int<nub>:alist:update int<nub>:var:user:fallback
                             index
                             int<nub>:var:debug:fills/index)

    ;; Set/create user's index.
    (int<nub>:alist:update user
                           index
                           int<nub>:var:debug:fills/index)))
;; (int<nub>:var:debug:fills/index:set :test 42)


;;------------------------------------------------------------------------------
;; Init/Reset all user's vars.
;;------------------------------------------------------------------------------

(defun nub:vars:init (user &optional list:debug:tags/common alist:prefixes alist:enabled? alist:sinks)
  "Registers USER and sets their default settings for output levels.

LIST:DEBUG:TAGS/COMMON should be a list of debugging keyword tags.
It is used for prompting end-users for debug tags to toggle.

ALIST:PREFIXES should be an alist of verbosity level to strings.

ALIST:ENABLED? should be an alist of verbosity level to t/nil.

ALIST:SINKS should be an alist of verbosity level to t/nil/function/list-of-functions.

Alists should have all output levels in them; for valid levels, see
`nub:output:levels'.
If an alist is nil, the default/fallback will be used instead.

Sets both current and backup values (backups generally only used for tests)."
  (int<nub>:init:user user)

  (when alist:enabled?
    (int<nub>:init:enabled? user alist:enabled?))

  (when alist:sinks
    (int<nub>:init:sink user alist:sinks))

  (when alist:prefixes
    (int<nub>:init:prefix user alist:prefixes))

  (when list:debug:tags/common
    (int<nub>:var:debug:tags/common:set user list:debug:tags/common)))


(defun nub:vars:reset (user)
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
;; (nub:vars:reset :test)


(defun nub:vars:terminate (user)
  "Remove USER and their settings from nub (initialized/backup values too)."
  ;;---
  ;; Allow multiple calls or calls for non-existant users.
  ;;---
  ;; (int<nub>:user:exists? "int<nub>:var:reset" user :error)

  ;;---
  ;; Delete user's output settings.
  ;;---
  (int<nub>:alist:delete user
                         int<nub>:var:enabled?)
  (int<nub>:alist:delete user
                         int<nub>:var:enabled?:backup)

  (int<nub>:alist:delete user
                         int<nub>:var:sink)
  (int<nub>:alist:delete user
                         int<nub>:var:sink:backup)

  (int<nub>:alist:delete user
                         int<nub>:var:prefix)
  (int<nub>:alist:delete user
                         int<nub>:var:prefix:backup)

  ;;---
  ;; Delete user's debug settings.
  ;;---
  (int<nub>:alist:delete user
                         int<nub>:var:debugging)

  (int<nub>:alist:delete user
                         int<nub>:var:debug:tags)

  (int<nub>:alist:delete user
                         int<nub>:var:debug:tags/common)

  ;;---
  ;; Final step: Delete the actual user.
  ;;---
  (int<nub>:terminate:user user)

  nil)


(defun int<nub>:vars:nuke/tactical ()
  "Delete all of everything (except `int<nub>:var:user:fallback'; they're cool)."
  ;; Delete all users except `int<nub>:var:user:fallback'.

  (message "\nNuking `nub' variables...")

  ;;---
  ;; Delete output settings.
  ;;---
  (message "  `int<nub>:var:enabled?'")
  (dolist (user-assoc int<nub>:var:enabled?)
    (let ((user (car user-assoc)))
      (unless (eq user int<nub>:var:user:fallback)
        (message "    - %S" user)
        (int<nub>:alist:delete user
                               int<nub>:var:enabled?))))

  (message "  `int<nub>:var:enabled?:backup'")
  (dolist (user-assoc int<nub>:var:enabled?:backup)
    (let ((user (car user-assoc)))
      (unless (eq user int<nub>:var:user:fallback)
        (message "    - %S" user)
        (int<nub>:alist:delete user
                               int<nub>:var:enabled?:backup))))

  (message "  `int<nub>:var:sink'")
  (dolist (user-assoc int<nub>:var:sink)
    (let ((user (car user-assoc)))
      (unless (eq user int<nub>:var:user:fallback)
        (message "    - %S" user)
        (int<nub>:alist:delete user
                         int<nub>:var:sink))))

  (message "  `int<nub>:var:sink:backup'")
  (dolist (user-assoc int<nub>:var:sink:backup)
    (let ((user (car user-assoc)))
      (unless (eq user int<nub>:var:user:fallback)
        (message "    - %S" user)
        (int<nub>:alist:delete user
                               int<nub>:var:sink:backup))))

  (message "  `int<nub>:var:prefix'")
  (dolist (user-assoc int<nub>:var:prefix)
    (let ((user (car user-assoc)))
      (unless (eq user int<nub>:var:user:fallback)
        (message "    - %S" user)
        (int<nub>:alist:delete user
                               int<nub>:var:prefix))))

  (message "  `int<nub>:var:prefix:backup'")
  (dolist (user-assoc int<nub>:var:prefix:backup)
    (let ((user (car user-assoc)))
      (unless (eq user int<nub>:var:user:fallback)
        (message "    - %S" user)
        (int<nub>:alist:delete user
                               int<nub>:var:prefix:backup))))

  ;;---
  ;; Delete debug settings.
  ;;---
  (message "  `int<nub>:var:debugging'")
  (dolist (user-assoc int<nub>:var:debugging)
    (let ((user (car user-assoc)))
      (unless (eq user int<nub>:var:user:fallback)
        (message "    - %S" user)
        (int<nub>:alist:delete user
                               int<nub>:var:debugging))))

  (message "  `int<nub>:var:debug:tags'")
  (dolist (user-assoc int<nub>:var:debug:tags)
    (let ((user (car user-assoc)))
      (unless (eq user int<nub>:var:user:fallback)
        (message "    - %S" user)
        (int<nub>:alist:delete user
                               int<nub>:var:debug:tags))))

  (message "  `int<nub>:var:debug:tags/common'")
  (dolist (user-assoc int<nub>:var:debug:tags/common)
    (let ((user (car user-assoc)))
      (unless (eq user int<nub>:var:user:fallback)
        (message "    - %S" user)
        (int<nub>:alist:delete user
                               int<nub>:var:debug:tags/common))))

  ;;---
  ;; Final step: Delete the actual users.
  ;;---
  (message "  `int<nub>:var:users'")
  (dolist (user int<nub>:var:users)
    (message "    - %S" user))
  (setq int<nub>:var:users nil)

  (message "\nDone.")
  nil)
;; (int<nub>:vars:nuke/tactical)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub 'variables)
