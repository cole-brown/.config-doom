;;; output/nub/api.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Initialization
;;------------------------------------------------------------------------------

(defun nub:init (user &optional list:debug:tags/common alist:level/prefixes alist:level/enabled? alist:level/sinks)
  "Registers USER and sets their default settings for output levels.

USER should be a keyword.

LIST:DEBUG:TAGS/COMMON should be a list of debugging keyword tags.
It is used for prompting end-users for debug tags to toggle.

ALIST:LEVEL/PREFIXES should be an alist of verbosity level to strings.

ALIST:LEVEL/ENABLED? should be an alist of verbosity level to t/nil.

ALIST:LEVEL/SINKS should be an alist of verbosity level to t/nil/function/list-of-functions.

Alists should have all output levels in them; for valid levels, see
`nub:output:levels'.
  - If an alist is nil, the default/fallback will be used instead.

Sets both current and backup values (backups generally only used for tests).

Examples:
  (nub:init :jeff)
  (nub:init :glados
            ;;---
            ;; These are just for prompts in the debug commands.
            ;;---
            '(:init :config :cake)
            ;;---
            ;; These are the defaults, FYI...
            ;;---
            ;; prefixes per level:
            '((:error . \"[ERROR   ]: \")
              (:warn  . \"[WARN    ]: \")
              (:info  . \"[INFO    ]: \")
              ;; Noticibly different so when debugging any error/warning messages stand out if all sent to the same buffer?
              (:debug . \"[   debug]: \"))
            ;; enabled per level:
            '((:error . t)
              (:warn  . t)
              (:info  . t)
              (:debug . t))
            ;; sinks per level:
            '((:error . error)
              (:warn  . warn)
              (:info  . message)
              (:debug . message)))"
  (int<nub>:init:user "nub:vars:init" user)
  (nub:vars:init user
                 list:debug:tags/common
                 alist:level/prefixes
                 alist:level/enabled?
                 alist:level/sinks))


;;------------------------------------------------------------------------------
;; ERROR output / `:error' level
;;------------------------------------------------------------------------------

(defun nub:error (user caller formatting &rest args)
  "Output an error message.

Format message output for the USER with CALLER function name/info string, then
output the message with FORMATTING and ARGS to the correct place according to
USER's current sink(s) for the `:error' level (default is the `error' function).

Uses FORMATTING string/list-of-strings with `int<nub>:output:format' to create
the message format, then applies that format plus any ARGS to the sink
function."
  (apply #'nub:output
         user
         :error
         caller
         formatting
         args))


;;------------------------------------------------------------------------------
;; WARN output / `:warn' level
;;------------------------------------------------------------------------------

(defun nub:warn (user caller formatting &rest args)
  "Output an warn message.

Format message output for the USER with CALLER function name/info string, then
output the message with FORMATTING and ARGS to the correct place according to
USER's current sink(s) for the `:warn' level (default is the `warn' function).

Uses FORMATTING string/list-of-strings with `int<nub>:output:format' to create
the message format, then applies that format plus any ARGS to the sink
function."
  (apply #'nub:output
         user
         :warn
         caller
         formatting
         args))


;;------------------------------------------------------------------------------
;; INFO output / `:info' level
;;------------------------------------------------------------------------------

(defun nub:info (user caller formatting &rest args)
  "Output an info message.

Format message output for the USER with CALLER function name/info string, then
output the message with FORMATTING and ARGS to the correct place according to
USER's current sink(s) for the `:info' level (default is the `message'
function).

Uses FORMATTING string/list-of-strings with `int<nub>:output:format' to create
the message format, then applies that format plus any ARGS to the sink
function."
  (apply #'nub:output
         user
         :info
         caller
         formatting
         args))


;;------------------------------------------------------------------------------
;; DEBUG output / `:debug' level
;;------------------------------------------------------------------------------
;; See 'debug.el' for `nub:debug' and other debug APIs.
