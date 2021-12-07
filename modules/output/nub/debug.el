;;; output/nub/debug.el -*- lexical-binding: t; -*-

;;; Commentary:

;; "Simple" debugging functionality for layout.
;;
;; ...it was simple enough at one point. Probably before all the tagging stuff.


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║              Oh, you /don't/ want any bugs. Right; ok...               ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                    How to Hide Bugs 101: Look for them.                    ;;
;;                                 ──────────                                 ;;


(imp:require :nub 'alist)
(imp:require :nub 'utils)
(imp:require :nub 'variables)
(imp:require :nub 'output)


;;------------------------------------------------------------------------------
;; Notes
;;------------------------------------------------------------------------------

;;------------------------------
;; Future Funcionality?
;;------------------------------
;;
;; TODO: Indentation levels?
;;   - [ ] Automatic based on call stack?
;;   - [ ] Manually based on an `int<nub>:debug' parameter?
;;   - [X] Manually based off of calls to `int<nub>:debug:func'.


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst int<nub>:debug:fills
  '("  "
    "- ")
  "List of characters to use for alternating fill/padding strings.")


(defvar int<nub>:debug:fills/index 0
  "Next fill/padding to use from `int<nub>:debug:fills'.")


;;------------------------------------------------------------------------------
;; Commands: Debugging Status
;;------------------------------------------------------------------------------

(defun int<nub>:debug:status/message (user)
  "Output debugging status and current debugging tags for USER."
  (let ((debugging (int<nub>:var:debugging user))
        (tags      (int<nub>:var:debug:tags user)))
    (message (concat "%s\n"
                     "  user: %s\n"
                     "  tags: %s")
             (if debugging
                 "[DEBUGGING]"
               "[disabled]")

             user

             ;; What to display for tags depends on if debugging (for `nil' case).
             (if debugging
                 (if (null tags)
                     ;; `nil' here means 'debug everything'.
                     "nil -> (all debug output)"
                   (cl-sort tags
                            #'string-lessp
                            :key (lambda (element) (downcase (symbol-name element)))))
               ;; `nil' here doesn't mean much since debugging isn't active...
               ""))))


(defun nub:debug/status (user)
  "Get message with status of debugging toggle, active debug tags."
  (interactive)
  (int<nub>:debug:status/message user))


;;------------------------------------------------------------------------------
;; Commands: Debugging Toggle
;;------------------------------------------------------------------------------

(defvar int<nub>:history:debug:toggle nil
  "History variable for the `nub:debug/toggle' command.")

(defun nub:debug/toggle (user)
  "Toggle debugging for the USER."
  (interactive
   (list (completing-read "Toggle Debug for User: "
                          int<nub>:var:users
                          nil
                          'confirm
                          nil
                          int<nub>:history:debug:toggle)))
  ;; Toggle debug flag and display status after toggle.
  (int<nub>:var:debugging:set user :toggle)
  (int<nub>:debug:status/message user))


;;------------------------------------------------------------------------------
;; Commands: Debugging Tags
;;------------------------------------------------------------------------------

(defvar int<nub>:history:debug:tag nil
  "History variable for the `nub:debug/toggle' command.")


(defun nub:debug:tag (user tag)
  "Toggle a debugging keyword TAG for the USER."
  (interactive
   (list (completing-read "Debug User: "
                          int<nub>:var:users
                          nil
                          'confirm
                          nil
                          int<nub>:history:debug:toggle)
         (completing-read "Toggle Debug Tag: "
                          (int<nub>:var:debug:tags/common user)
                          nil
                          'confirm
                          nil
                          int<nub>:history:debug:tag)))

   ;; Convert to keyword.
  (let ((keyword (int<nub>:normalize->keyword tag)))
     ;; Toggle in/out of the active tags.
    (if (int<nub>:var:debug:tag:set keyword :toggle)
        ;; Toggled it on.
        (message "User '%s' added debug tag: %S\n  tags: %S"
                 user
                 keyword
                 (int<nub>:var:debug:tags user))

      ;; Toggled it off.
      (message "User '%s' removed debug tag: %S\n  tags: %S"
               user
               keyword
               (int<nub>:var:debug:tags user)))))


(defun nub:debug/tag:clear (user)
  "Reset USER's debugging tags to nil."
  (interactive)
  (int<nub>:var:debug:tags user nil)
  (message "User '%s' cleared all debug tags: %S"
           user
           (int<nub>:var:debug:tags user)))


;;------------------------------------------------------------------------------
;; String Functions (message, fills)
;;------------------------------------------------------------------------------

(defun int<nub>:debug:fill/clear ()
  "Setup fills for debug messages."
  (setq int<nub>:debug:fills/index 0))


(defun int<nub>:debug:fill (len)
  "CREATE a string of length LEN using next fill string as determined by
`int<nub>:debug:fills' and `int<nub>:debug:fills/index'."
  ;; Ensure string is proper length.
  (truncate-string-to-width
   (let* ((fill-str (elt int<nub>:debug:fills int<nub>:debug:fills/index))
          (fill-len (length fill-str))
          (times (1+ (/ len fill-len))) ; +1 for int math divide flooring odds.
          fill-list)
     ;; Create the filling from our "whatever width you want" strings by making a long-enough list of the fills.
     (while (> times 0)
       (setq fill-list (cons fill-str fill-list))
       ;; Loop conditional.
       (setq times (1- times)))

     ;; Update index for next time.
     (setq int<nub>:debug:fills/index (% (1+ int<nub>:debug:fills/index)
                                              (length int<nub>:debug:fills)))
     ;; Have long-enough list - convert to a string.
     (apply #'concat fill-list))
   len))
;; (int<nub>:debug:fill 41)
;; (int<nub>:debug:fill 42)
;; (length (int<nub>:debug:fill 41))
;; (length (int<nub>:debug:fill 42))


;;------------------------------------------------------------------------------
;; Debugging Functions
;;------------------------------------------------------------------------------

;; TODO: this has wrong name.
(defun int<nub>:var:debugging? (user caller tags)
  "Returns non-nil if USER is debugging for anything in the list of TAGS.

Debugging when `int<nub>:var:debugging' is non-nil for USER and one of these
is true:
  - `int<nub>:debug:tags' for the user is nil
    + No specific debugging tags desired == all tags active.
  - `int<nub>:debug:tags' for the user is non-nil AND matches one or more
     of the tags in TAGS.
    + Looking for a specific debug tag and found it."
  (cond
   ;;------------------------------
   ;; [ERROR] Forgot to tag your debugging call!
   ;;------------------------------
   ((not tags)
    (int<nub>:error "int<nub>:var:debugging?"
                    '(:newlines .
                      ("This debug message has not been tagged!"
                       "  user:   %S"
                       "  caller: %S"
                       "  tags:   %S"
                     caller
                     user
                     tags))))

   ;;------------------------------
   ;; Not Debugging -> Never.
   ;;------------------------------
   ;; Debugging disabled is always a "no".
   ((not (int<nub>:var:debugging user))
    nil)

   ;;------------------------------
   ;; Debugging -> Check Tags
   ;;------------------------------

   ;; If there are no `int<nub>:debug:tags', then it is automatically a yes.
   ((not (int<nub>:debug:tags user))
    t)

   ;; The intersection of the sets `tags' and `int<nub>:debug:tags' will be
   ;; non-nil if any TAGS are active.
   (t
    (seq-intersection tags (int<nub>:debug:tags user)))))


(defmacro int<nub>:debug/message? (user caller tags message? msg &rest args)
  "Print out a debug message or `message'.

Will only evaluate CALLER, MSG, and ARGS when if MESSAGE? is non-nil or
if debugging.

If MESSAGE? is non-nil, always prints message. Otherwise only
prints if debugging (`int<nub>:var:debugging') and if any tag in
TAGS matches USER's active debugging tags (`int<nub>:debug:tags').

CALLER should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS should be the `message' arguments."
  (declare (indent 4))
  `(let ((int<nub>:macro:user ,user)
         (int<nub>:macro:tags ,tags))
     ;; Check with `int<nub>:var:debugging?' first so that missing debug tags always error.
     (cond
      ;; Only message (at debug level) if passed checks.
      ((int<nub>:var:debugging? int<nub>:macro:user int<nub>:macro:tags)
       (int<nub>:output user :debug ,caller ,msg ,@args))

      ;; Always message (at debug level) - regardless of debugging toggle/flags.
      (,message?
       (int<nub>:output user :debug ,caller ,msg ,@args))

      ;; Not debugging and not allowing message through otherwise.
      (t
       nil))))
;; int<nub>:var:debugging
;; int<nub>:debug:tags
;; (setq int<nub>:var:debugging nil int<nub>:debug:tags nil)
;; (int<nub>:var:debugging? '(:jeff))
;; (int<nub>:debug/message? "test-func" '(:jeff) nil (message "test"))
;; (int<nub>:debug/message? "test-func" '(:jeff) :always-message (message "test"))


(defmacro int<nub>:debug (user caller tags msg &rest args)
  "Print out a debug message.

Will only evaluate MSG, and ARGS when debugging.

Only prints if debugging (`int<nub>:var:debugging') and if any tag in TAGS
matches USER's active debugging tags (`int<nub>:debug:tags').

CALLER should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS should be the `message' arguments."
  (declare (indent 3))

  `(let ((int<nub>:macro:user   ,user)
         (int<nub>:macro:caller ,caller))

     (when (int<nub>:var:debugging? int<nub>:macro:user
                                     int<nub>:macro:caller
                                     ,tags)
     ;; (ignore caller msg args)))
        (int<nub>:output int<nub>:macro:user
                         :debug
                         int<nub>:macro:caller
                         ,msg
                         ,@args))))
;; Make sure it only evals args when debugging:
;; (int<nub>:debug "test-func" nil (message "test"))
;; (int<nub>:debug "test-func" '(:derive) (message "test"))
;; (int<nub>:debug "test-func" '(:jeff) (message "test"))
;; (let ((caller "test-func")
;;       (tags '(:derive))
;;       (msg "test message"))
;;   (int<nub>:debug caller tags msg))


(defun int<nub>:debug:func (user debug/name debug/tags start-or-end &rest value)
  "Print out start/end function message, with optional VALUE.

Prints start message when START-OR-END is `:start'.
Prints end message w/ optional return value when START-OR-END is `:end'.

VALUEs are optional and should be:
  - nil
  - `cons' pairs of: '(name . value)"
  (declare (indent 3))
  (let ((func/name "int<nub>:debug:func")
        value/formatted)

    ;;------------------------------
    ;; Error checks.
    ;;------------------------------
    (unless (memq start-or-end '(:start :end))
      (int<nub>:error func/name
                      '(:newlines .
                        ("START-OR-END must be one of: %S; got: %S."
                         "  user:         %S"
                         "  debug/name:   %S"
                         "  debug/tags:   %S"
                         "  start-or-end: %S"
                         "  value:        %S"))
                      '(:start :end)
                      start-or-end
                      user
                      debug/name
                      debug/tags
                      start-or-end
                      value))

    ;;------------------------------
    ;; Format output.
    ;;------------------------------
    ;; No value alist - no output string.
    (cond ((not value)
           (setq value/formatted ""))

          ;; Invalid value alist - error out.
          ((not (int<nub>:alist:alist? value))
           (int<nub>:error func/name
                           '(:newlines .
                             ("VALUE is invalid for `%S'! Expecting `&rest VALUE' to be an alist. Got: %S"
                              "  user:         %S"
                              "  debug/name:   %S"
                              "  debug/tags:   %S"
                              "  start-or-end: %S"
                              "  value:        %S"))
                           start-or-end
                           value
                           user
                           debug/name
                           debug/tags
                           start-or-end
                           value))

          ;; Format nicely into columns.
          (t
           (let ((width/name 0)
                 values/print
                 fmt)
             ;; Convert names to strings, figure out print formatting.
             (dolist (input value)
               (let ((key (car input))
                     (value (cdr input)))
                 (if (eq :title key)
                     ;; Just push the title string.
                     (push (cons value "") values/print)
                   ;; Push formatted (to-string'd) key and value.
                   (let ((key/formatted (format "    %s:" key)))
                     (push (cons key/formatted value) values/print)
                     (setq width/name (max (length key/formatted)
                                           width/name))))))
             ;; ":" separator already provided above.
             (setq fmt (concat "%-" (number-to-string width/name) "s %S\n"))

             ;; Convert alist of strings to a single string.
             (dolist (input (nreverse values/print))
               (setq value/formatted (concat value/formatted
                                             (format fmt (car input) (cdr input))))))))

    ;;------------------------------
    ;; Start-of-function messages.
    ;;------------------------------
    (cond ((and (null value/formatted)
                (eq :start start-or-end))
           (int<nub>:debug
               user
               debug/name
               debug/tags
             '("\n"
               "---[BEGIN]------>\n")))

          ;; VALUE exists and is valid; print it too.
          ((eq :start start-or-end)
           ;; Print start w/ input vars.
           (int<nub>:debug
               user
               debug/name
               debug/tags
             '("\n"
               "---[BEGIN]------>\n"
               "  ---[INPUTS]--->\n"
               "%s")
             value/formatted))

          ;;------------------------------
          ;; End-of-function messages.
          ;;------------------------------
          ;; No value provided; just print end.
          ((and (null value/formatted)
                (eq :end start-or-end))
           (int<nub>:debug
               user
               debug/name
               debug/tags
             '("\n"
               "<--[END]-------\n")))

          ;; `:end' + VALUE; print end w/ return VALUE.
          ((eq :end start-or-end)
           (int<nub>:debug
               user
               debug/name
               debug/tags
               '("\n"
                 "<--[END]-------\n"
                 "  <--[RETURN]--\n"
                 "%s")
             value/formatted))

          ;;------------------------------
          ;; Error: Bad START-OR-END
          ;;------------------------------
          (t
           (int<nub>:error func/name
                           '(:newlines .
                             ("Invalid start/end tag! Must be one of: %S; got: %S."
                              "  user:       %S"
                              "  debug/name: %S"
                              "  debug/tags: %S"
                              "  value:      %S"
                              "  value/formatted:"
                              "%S"))
                            '(:start :end)
                            start-or-end
                            user
                            debug/name
                            debug/tags
                            value
                            value/formatted)))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub 'debug)
