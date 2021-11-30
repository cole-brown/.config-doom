;;; output/nub/debug.el -*- lexical-binding: t; -*-

;;; Commentary:

;; "Simple" debugging functionality for layout.
;;
;; ...it was simple enough at one point. Probably before all the tagging stuff.


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║               Nub: /noun/ A small lump or protuberance.                ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                    How to Hide Bugs 101: Look for them.                    ;;
;;                                 ──────────                                 ;;


(imp:require :nub 'alist)
(imp:require :nub 'utils)
(imp:require :nub 'output)


;;------------------------------------------------------------------------------
;; Notes
;;------------------------------------------------------------------------------

;;------------------------------
;; Future Funcionality?
;;------------------------------
;;
;; Indentation levels?
;;   - Automatic based on call stack?
;;   - Manually based on an `int<nub>:debug' parameter?


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar int<nub>:debugging nil
  "Alist of nub-user-keyword to boolean debug flag. Non-nil means debugging is active.")


(defvar int<nub>:debug:tags nil
  "Alist of nub-user-keyword to list of active debugging keyword tags. Any
keyword matched in the list will be printed out when debugging is active.

If there are no tags in the list, or the list is nil, everything
will be printed.")


(defvar int<nub>:debug:tags/common nil
  "List of active debugging keyword tags. Any keyword matched in
the list will be printed out when debugging is active.

Any keyword can be used regardless of this list - these will be provided to
`nub:debug/toggle-tag' as potential candidates
to toggle.")


(defconst int<nub>:debug:fills
  '("  "
    "- ")
  "List of characters to use for alternating fill/padding strings.")


(defvar int<nub>:debug:fills/index 0
  "Next fill/padding to use from `int<nub>:debug:fills'.")


;;------------------------------------------------------------------------------
;; Commands: Debugging Status
;;------------------------------------------------------------------------------

(defun nub:debug/status ()
  "Get message with status of debugging toggle, active debug tags."
  (interactive)
  (int<nub>:cmd:run
   (message "TODO USER HERE: %s\n  tags: %s"
            (if int<nub>:debugging
                "[DEBUGGING]"
              "[disabled]")
            (if (null int<nub>:debug:tags)
                "()"
              int<nub>:debug:tags))))


;;------------------------------------------------------------------------------
;; Commands: Debugging Toggle
;;------------------------------------------------------------------------------

(defun nub:debug/toggle ()
  "Toggle debugging for the USER."
  (interactive)
  (int<nub>:cmd:run
   (setq int<nub>:debugging (not int<nub>:debugging))
   (message "int<nub>:debugging: %s%s"
            (if int<nub>:debugging
                "[ENABLED]"
              "[disabled]")
            (if int<nub>:debugging
                (if (not int<nub>:debug:tags)
                    " (all debug output)"
                  (format " with tags: %S" int<nub>:debug:tags))
              ""))))


;;------------------------------------------------------------------------------
;; Commands: Debugging Tags
;;------------------------------------------------------------------------------

(defun nub:debug/tag:toggle (tag)
  "Toggle a debugging keyword TAG for the USER."
  (interactive (list (completing-read "Toggle Debug Tag: "
                                      int<nub>:debug:tags/common
                                      nil
                                      'confirm)))
  (int<nub>:cmd:run
   ;; Convert to keyword.
   (let ((keyword (int<nub>:normalize->keyword tag)))
     ;; Toggle in/out of the active tags.
     (if (memq keyword int<nub>:debug:tags)
         (prog1
             (setq int<nub>:debug:tags (remove keyword int<nub>:debug:tags))
           (message "'TODO USER' removed debug tag: %S\n  tags: %S"
                    keyword int<nub>:debug:tags))
       (prog1
           (push keyword int<nub>:debug:tags)
         (message "'TODO USER' added debug tag: %S\n  tags: %S"
                  keyword int<nub>:debug:tags))))))


(defun nub:debug/tag:clear ()
  "Reset debugging tags to nil."
  (interactive)
  (int<nub>:cmd:run
   (setq int<nub>:debug:tags nil)
   (message "'TODO USER' cleared debug tags.\n  tags: %S"
            int<nub>:debug:tags)))


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

(defun int<nub>:debugging? (tags)
  "Returns non-nil if debugging for the list of TAGS.

Never debugging when `int<nub>:debugging' is nil.

Debugging when `int<nub>:debugging' is non-nil and one of these is true:
  - `int<nub>:debug:tags' is nil
    + No specific debugging tags desired == all tags active.
  - `int<nub>:debug:tags' is non-nil AND matches one or more of the tags
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
   ((not int<nub>:debugging)
    nil)

   ;;------------------------------
   ;; Debugging -> Check Tags
   ;;------------------------------

   ;; If there are no `int<nub>:debug:tags', then it is automatically a yes.
   ((not int<nub>:debug:tags)
    t)

   ;; The intersection of the sets `tags' and `int<nub>:debug:tags' will be
   ;; non-nil if any TAGS are active.
   (t
    (seq-intersection tags int<nub>:debug:tags))))


(defmacro int<nub>:debug/message? (caller tags message? msg &rest args)
  "Print out a debug message or `message'.

Will only evaluate CALLER, MSG, and ARGS when if MESSAGE? is non-nil or
if debugging.

If MESSAGE? is non-nil, always prints message. Otherwise only
prints if debugging (`int<nub>:debugging') and if any tag in
TAGS matches active debugging tags (`int<nub>:debug:tags').

CALLER should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS should be the `message' arguments."
  (declare (indent 3))
  ;; Check with `int<nub>:debugging?' first so that missing debug tags always error.
  `(cond
    ;; Only message (at debug level) if passed checks.
    ((int<nub>:debugging? ,tags)
     (int<nub>:output :debug ,caller ,msg ,@args))

    ;; Always message (at debug level) - regardless of debugging toggle/flags.
    (,message?
     (int<nub>:output :debug ,caller ,msg ,@args))

    ;; Not debugging and not allowing message through otherwise.
    (t
     nil)))
;; int<nub>:debugging
;; int<nub>:debug:tags
;; (setq int<nub>:debugging nil int<nub>:debug:tags nil)
;; (int<nub>:debugging? '(:jeff))
;; (int<nub>:debug/message? "test-func" '(:jeff) nil (message "test"))
;; (int<nub>:debug/message? "test-func" '(:jeff) :always-message (message "test"))


(defmacro int<nub>:debug (caller tags msg &rest args)
  "Print out a debug message.

Will only evaluate CALLER, MSG, and ARGS when debugging.

Only prints if debugging (`int<nub>:debugging') and if any tag in TAGS
matches active debugging tags (`int<nub>:debug:tags').

CALLER should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS should be the `message' arguments."
  (declare (indent 2))

  `(when (int<nub>:debugging? ,tags)
     ;; (ignore caller msg args)))
     (int<nub>:output :debug ,caller ,msg ,@args)))
;; Make sure it only evals args when debugging:
;; (int<nub>:debug "test-func" nil (message "test"))
;; (int<nub>:debug "test-func" '(:derive) (message "test"))
;; (int<nub>:debug "test-func" '(:jeff) (message "test"))
;; (let ((caller "test-func")
;;       (tags '(:derive))
;;       (msg "test message"))
;;   (int<nub>:debug caller tags msg))


(defun int<nub>:debug:func (debug/name debug/tags start-or-end &optional value)
  "Print out start/end function message, with optional VALUE.

Prints start message when START-OR-END is `:start'.
Prints end message w/ optional return value when START-OR-END is `:end'.

VALUE is optional and should be:
  - If START-OR-END is `:start':
    + An alist of: '((input-symbol-name . input-symbol-value) ...)
  - If START-OR-END is `:end':
    + The return value.
  - If START-OR-END is `:end/list':
    + A alist of: '((key . value) ...)
      - This will be displayed similar to `:start' alist."
  (declare (indent 2))
  (let ((func/name/this "int<nub>:debug:func")
        value/formatted)

    ;;------------------------------
    ;; Format output?
    ;;------------------------------
    (when (memq start-or-end '(:start :end/list))
      ;; No value alist - no output string.
      (cond ((not value)
             (setq value/formatted ""))

            ;; Invalid value alist - error out.
            ((not (int<nub>:alist:alist? value))
             (int<nub>:output :error
                                   func/name/this
                                   "VALUE is invalid for `%S'! Must be an alist. Got: %S"
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
                                               (format fmt (car input) (cdr input)))))))))

    ;;------------------------------
    ;; Start-of-function messages.
    ;;------------------------------
    (cond ((and (null value/formatted)
                (eq :start start-or-end))
           (int<nub>:debug
               debug/name
               debug/tags
             '("\n"
               "---[BEGIN]------>\n")))

          ;; VALUE exists and is valid; print it too.
          ((eq :start start-or-end)
           ;; Print start w/ input vars.
           (int<nub>:debug
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
          ;; `:end' + VALUE; print end w/ return VALUE.
          ((and (eq :end start-or-end)
                value)
           (int<nub>:debug
               debug/name
               debug/tags
             '("\n"
               "<--[END]-------\n"
               "  <--[RETURN]-- %S")
             value))

          ;; No value provided; just print end.
          ((eq :end start-or-end)
           (int<nub>:debug
               debug/name
               debug/tags
             '("\n"
               "<--[END]-------\n")))


          ;; `:end/list' + VALUE; print end w/ formatted VALUE.
          ((eq :end/list start-or-end)
           (int<nub>:debug
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
           (int<nub>:output :error
                                 func/name/this
                                 "Invalid start/end tag! Must be `:start' or `:end'; got: %S"
                                 start-or-end)))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub 'debug)
