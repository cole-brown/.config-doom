;;; input/keyboard/debug.el -*- lexical-binding: t; -*-

;;; Commentary:

;; "Simple" debugging functionality for layout.
;;
;; ...it was simple enough at one point. Probably before all the tagging stuff.


;;------------------------------------------------------------------------------
;; Notes
;;------------------------------------------------------------------------------

;;------------------------------
;; Future Funcionality?
;;------------------------------
;;
;; Indentation levels?
;;   - Automatic based on call stack?
;;   - Manually based on an `int<keyboard>:debug' parameter?


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar int<keyboard>:debugging nil
  "Debug flag. Non-nil means debugging is active.")


(defvar int<keyboard>:debug:tags nil
  "List of active debugging keyword tags. Any keyword matched in
the list will be printed out when debugging is active.

If there are no tags in the list, or the list is nil, everything
will be printed.")


(defvar int<keyboard>:debug:tags/common
  '(;;------------------------------
    ;; States of Start-Up
    ;;------------------------------
    :init
    :config
    :finalize

    ;;------------------------------
    ;; Types of Keybinds
    ;;------------------------------
    :common
    :emacs
    :evil

    ;;------------------------------
    ;; Functionality
    ;;------------------------------
    ;; register.el - Registering keybinds.
    :register
    ;; layout.el - Deriving keys from in-progress/existing keybinds.
    :derive
    :derive/search
    ;; layout.el - Mapping keys to keybinds.
    :map
    :map/bind
    )
  "List of active debugging keyword tags. Any keyword matched in
the list will be printed out when debugging is active.

Any keyword can be used regardless of this list - these will be provided to
`input:keyboard/layout:debug/toggle-tag' as potential candidates
to toggle.")


(defconst int<keyboard>:debug:fills
  '("  "
    "- ")
  "List of characters to use for alternating fill/padding strings.")


(defvar int<keyboard>:debug:fills/index 0
  "Next fill/padding to use from `int<keyboard>:debug:fills'.")


;;------------------------------------------------------------------------------
;; Commands: Debugging Status
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:debug/status ()
  "Get message with status of debugging toggle, active debug tags."
  (interactive)
  (message ":input/keyboard/layout module: %s\n  tags: %s"
           (if int<keyboard>:debugging
               "[DEBUGGING]"
             "[disabled]")
           (if (null int<keyboard>:debug:tags)
               "()"
             int<keyboard>:debug:tags)))


;;------------------------------------------------------------------------------
;; Commands: Debugging Toggle
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:debug/toggle ()
  "Toggle debugging for ':input/keyboard/layout' module."
  (interactive)
  (setq int<keyboard>:debugging (not int<keyboard>:debugging))
  (message "int<keyboard>:debugging: %s%s"
           (if int<keyboard>:debugging
               "[ENABLED]"
             "[disabled]")
           (if int<keyboard>:debugging
               (if (not int<keyboard>:debug:tags)
                   " (all debug output)"
                 (format " with tags: %S" int<keyboard>:debug:tags))
             "")))


;;------------------------------------------------------------------------------
;; Commands: Debugging Tags
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:debug/tag:toggle (tag)
  "Toggle a debugging keyword tag for ':input/keyboard/layout' module."
  (interactive (list (completing-read "Toggle Debug Tag: "
                                      int<keyboard>:debug:tags/common
                                      nil
                                      'confirm)))
  ;; Convert to keyword.
  (let ((keyword (input//kl:normalize->keyword tag)))
    ;; Toggle in/out of the active tags.
    (if (memq keyword int<keyboard>:debug:tags)
        (prog1
            (setq int<keyboard>:debug:tags (remove keyword int<keyboard>:debug:tags))
          (message "':input/keyboard/layout' removed debug tag: %S\n  tags: %S"
                   keyword int<keyboard>:debug:tags))
      (prog1
          (push keyword int<keyboard>:debug:tags)
        (message "':input/keyboard/layout' added debug tag: %S\n  tags: %S"
                 keyword int<keyboard>:debug:tags)))))


(defun input:keyboard/layout:debug/tag:clear ()
  "Reset debugging tags to nil."
  (interactive)
  (setq int<keyboard>:debug:tags nil)
  (message "':input/keyboard/layout' cleared debug tags.\n  tags: %S"
           int<keyboard>:debug:tags))


;;------------------------------------------------------------------------------
;; String Functions (message, fills)
;;------------------------------------------------------------------------------

(defun int<keyboard>:debug:fill/clear ()
  "Setup fills for debug messages."
  (setq int<keyboard>:debug:fills/index 0))


(defun int<keyboard>:debug:fill (len)
  "CREATE a string of length LEN using next fill string as determined by
`int<keyboard>:debug:fills' and `int<keyboard>:debug:fills/index'."
  ;; Ensure string is proper length.
  (truncate-string-to-width
   (let* ((fill-str (elt int<keyboard>:debug:fills int<keyboard>:debug:fills/index))
          (fill-len (length fill-str))
          (times (1+ (/ len fill-len))) ; +1 for int math divide flooring odds.
          fill-list)
     ;; Create the filling from our "whatever width you want" strings by making a long-enough list of the fills.
     (while (> times 0)
       (setq fill-list (cons fill-str fill-list))
       ;; Loop conditional.
       (setq times (1- times)))

     ;; Update index for next time.
     (setq int<keyboard>:debug:fills/index (% (1+ int<keyboard>:debug:fills/index)
                                              (length int<keyboard>:debug:fills)))
     ;; Have long-enough list - convert to a string.
     (apply #'concat fill-list))
   len))
;; (int<keyboard>:debug:fill 41)
;; (int<keyboard>:debug:fill 42)
;; (length (int<keyboard>:debug:fill 41))
;; (length (int<keyboard>:debug:fill 42))


;;------------------------------------------------------------------------------
;; Debugging Functions
;;------------------------------------------------------------------------------

(defun int<keyboard>:debugging? (tags)
  "Returns non-nil if debugging for the list of TAGS.

Never debugging when `int<keyboard>:debugging' is nil.

Debugging when `int<keyboard>:debugging' is non-nil and one of these is true:
  - `int<keyboard>:debug/tags' is nil
    + No specific debugging tags desired == all tags active.
  - `int<keyboard>:debug/tags' is non-nil AND matches one or more of the tags
     in TAGS.
    + Looking for a specific tag and found it.
  - one of the keywords in TAGS list is an active debugging tag."
  (cond
   ;;------------------------------
   ;; [ERROR] Forgot to tag your debugging call!
   ;;------------------------------
   ((not tags)
    (error "debug message has not been tagged!"))

   ;;------------------------------
   ;; Not Debugging -> Never.
   ;;------------------------------
   ;; Debugging disabled is always a "no".
   ((not int<keyboard>:debugging)
    nil)

   ;;------------------------------
   ;; Debugging -> Check Tags
   ;;------------------------------

   ;; If there are no `int<keyboard>:debug:tags', then it is automatically a yes.
   ((not int<keyboard>:debug:tags)
    t)

   ;; The intersection of the sets `tags' and `int<keyboard>:debug:tags' will be
   ;; non-nil if any TAGS are active.
   (t
    (seq-intersection tags int<keyboard>:debug:tags))))


(defmacro int<keyboard>:debug (caller tags msg &rest args)
  "Print out a debug message.

Will only evaluate CALLER, MSG, and ARGS when debugging.

Only prints if debugging (`int<keyboard>:debugging') and if any tag in TAGS
matches active debugging tags (`int<keyboard>:debug:tags').

CALLER should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS should be the `message' arguments."
  (declare (indent 2))

  `(when (int<keyboard>:debugging? ,tags)
     ;; (ignore caller msg args)))
     (int<keyboard>:output :debug ,caller ,msg ,@args)))
;; Make sure it only evals args when debugging:
;; (int<keyboard>:debug "test-func" nil (message "test"))
;; (int<keyboard>:debug "test-func" '(:derive) (message "test"))
;; (int<keyboard>:debug "test-func" '(:jeff) (message "test"))
;; (let ((caller "test-func")
;;       (tags '(:derive))
;;       (msg "test message"))
;;   (int<keyboard>:debug caller tags msg))


(defmacro int<keyboard>:debug/message? (caller tags message? msg &rest args)
  "Print out a debug message or `message'.

Will only evaluate CALLER, MSG, and ARGS when if MESSAGE? is non-nil or
if debugging.

If MESSAGE? is non-nil, always prints message. Otherwise only
prints if debugging (`int<keyboard>:debugging') and if any tag in
TAGS matches active debugging tags (`int<keyboard>:debug:tags').

CALLER should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS should be the `message' arguments."
  (declare (indent 3))
  `(if ,message?
       ;; Always message (at debug level) - regardless of debugging toggle/flags.
       (int<keyboard>:output :debug ,caller ,msg ,@args)
     ;; Only message (at debug level) if passed checks.
     (when (and int<keyboard>:debugging
                (int<keyboard>:debug:tagged? ,tags))
       (int<keyboard>:output :debug ,caller ,msg ,@args))))
;; (int<keyboard>:debug/message? "test-func" '(:jeff) nil (message "test"))
;; (int<keyboard>:debug/message? "test-func" '(:jeff) :always-message (message "test"))



;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
