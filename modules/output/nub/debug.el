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


(imp:require :nub 'internal)
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


(defvar int<nub>:debug:user/history nil
  "History of users chosen in `int<nub>:prompt:user'.")


;;------------------------------------------------------------------------------
;; Command Helpers
;;------------------------------------------------------------------------------

(defun int<nub>:prompt:generic (prompt options history)
  "Prompt the user to enter a value w/ history, completion, etc.

PROMPT should be the prompt to show the user. ': ' will be appended to the end.

OPTIONS should be a list of all known valid options to choose.

HISTORY should be nil or a _quoted_ variable to hold history for that command's
prompt of that variable.

Returns the string value entered/chosen by the user."
  (completing-read (concat prompt ": ")
                   options
                   nil
                   'confirm
                   nil
                   history))
;; (setq test-history nil)
;; (setq test-options '(:a b "c"))
;; (int<nub>:prompt:generic "Pick a card; any card" test-options 'test-history)


(defun int<nub>:prompt:user (caller prompt &optional output-as-list)
  "Prompt the user to choose what nub user they are.

CALLER should be the string name of the calling function.

PROMPT should be the prompt to show the user. ': ' will be appended to the end.

Return value has 2 modes:
  - OUTPUT-AS-LIST is non-nil:
    - Returns a 1-tuple list of:
      - a valid nub user keyword or
      - nil (and outputs a message about failure)
  - OUTPUT-AS-LIST is nil:
    - Returns a valid nub user keyword or nil.

Usage:
  (defun int<nub>:debug:foo (user)
    (interactive (int<nub>:prompt:user \"int<nub>:debug:foo\"
                                       \"The User\"
                                       :list))
    (if (null user)
        <do something about invalid user>
      ;; USER is a valid nub user keyword.
      ...))

  (defun int<nub>:debug:bar (user other-thing)
    (interactive (list (int<nub>:prompt:user \"int<nub>:debug:foo\"
                                             \"The User\")
                       ;; Prompt for OTHER-THING here.
                       ...
                  ))
    (if (null user)
        <do something about invalid user>
      ;; USER is a valid nub user keyword.
      ...))"
  ;; Get something from the user.
  (let ((func.name (int<nub>:format:callers "int<nub>:prompt:user"
                                            caller))
        (choice.string (int<nub>:prompt:generic prompt
                                                int<nub>:var:users
                                                'int<nub>:debug:user/history))
        choice.keyword)
    ;; Validate the choice.
    ;; But first we need to convert it into a keyword from a string.
    (setq choice.keyword (int<nub>:normalize->keyword choice.string))

    ;; Invalid User: Message about it.
    (unless (int<nub>:user:exists? func.name choice.keyword nil)
      (message (int<nub>:format :newlines
                                func.name
                                "Input/chosen user isn't a registered `nub' user."
                                "--choice: %s -> %S"
                                "--users:"
                                "%s"
                                "--history:"
                                "%s")
               choice.string choice.keyword
               (pp-to-string int<nub>:var:users)
               (pp-to-string int<nub>:debug:user/history))
      ;; And set return value to nil.
      (setq choice.keyword nil))

    ;; Return either as `(list keyword)' or as `keyword'.
    (if output-as-list
        (list choice.keyword)
      choice.keyword)))
;; (int<nub>:prompt:user "test" "user plz")
;; (int<nub>:prompt:user "test" "user plz" :list)


(defun int<nub>:prompt:debug:tag (caller prompt user)
  "Prompt the user to choose a single debug tag.

CALLER should be the string name of the calling function.

PROMPT should be the prompt to show the user. ': ' will be appended to the end.

USER should be a valid `nub' user keyword.

Returns a 1-tuple list of:
  - a valid nub user keyword or
  - nil (and outputs a message about failure)

Usage:
  (defun int<nub>:debug:foo (user tag)
    (interactive (list (int<nub>:prompt:user \"int<nub>:debug:foo\")
                       (int<nub>:prompt:debug:tag \"int<nub>:debug:foo\"))
    (if (null user)
        <do something about invalid user>
      ;; Do something about tag.
      ...))"
  (let ((func.name (int<nub>:format:callers "int<nub>:prompt:debug:tag"
                                            caller))
        tag.string)
    ;; Make sure user is valid.
    (if (null (int<nub>:user:exists? func.name user nil))
        ;; Invalid - message about it and return nil.
        (progn
          (message (int<nub>:format func.name
                                    ": USER param isn't a registered `nub' user: %S")
                   user)
          nil)

      ;; Now we can get the user's tags-for-interactive-purposes and prompt for a tag.
      (setq tag.string (int<nub>:prompt:generic prompt
                                                (int<nub>:var:debug:tags/common user)
                                                'int<nub>:history:debug:tag))
      ;; Return nil or tag keyword.
      (when (and (stringp tag.string)
                 (> (length tag.string) 0))
        (int<nub>:normalize->keyword tag.string)))))
;; (int<nub>:prompt:debug:tag "test" "tag plz" :test<nub/output>::int<nub>:output)


(defun int<nub>:prompt:debug:tags (caller prompt user &rest quit)
  "Prompt the user to choose a single debug tag at a time until they quit.
Returns a list of the tag keywords chosen.

CALLER should be the string name of the calling function.

PROMPT should be the prompt to show the user. ': ' will be appended to the end.

USER should be a valid `nub' user keyword.

QUIT should be a list of strings to stop the loop. If nil, it will stop on
nil/empty input only."
  (let ((func.name (int<nub>:format:callers "int<nub>:prompt:debug:tag"
                                            caller)))
    ;; Make sure user is valid.
    (if (null (int<nub>:user:exists? func.name user nil))
        ;; Invalid - message about it and return nil.
        (progn
          (message (int<nub>:format func.name
                                    ": USER param isn't a registered `nub' user: %S")
                   user)
          nil)
      ;; Configure our quit keywords.
      (let* ((quit:matches (if quit
                               ;; Have quit stuff - convert to keyword so we can check
                               ;; against `int<nub>:prompt:debug:tag' output.
                               (seq-map #'int<nub>:normalize->keyword
                                        quit)
                             nil))
             tag
             tags
             (continue t))
        ;; `nil' is always a quit value.
        (push nil quit:matches)

        ;; Prompt for tags until you get something that matches QUIT.
        (while continue
          (let ((prompt (concat prompt
                                (if tags
                                    (concat " (tags: "
                                            (string-join (seq-map #'symbol-name tags)
                                                         ", ")
                                            ")")
                                  "")
                                " [done: '"
                                (if quit
                                    (nth 0 quit)
                                  "")
                                "']")))
            (setq tag (int<nub>:prompt:debug:tag caller prompt user))
            (if (memq tag quit:matches)
                (setq continue nil)
              (push tag tags))))

        ;; Return whatever was collected.
        tags))))
;; (int<nub>:prompt:debug:tags "test" "tag plz" :test<nub/output>::int<nub>:output)


;;------------------------------------------------------------------------------
;; Debugging for Tags?
;;------------------------------------------------------------------------------

;; This is used by `int<nub>:debug'
(defun int<nub>:debug:active? (user caller tags &optional nil-as-wildcard)
  "Returns non-nil if USER is currently debugging for anything in the
list of TAGS.

CALLER should be calling function's string name.

Debugging when `int<nub>:var:debugging' is non-nil for USER and one of these
is true:
  - `int<nub>:debug:tags' for the user is nil
    + No specific debugging tags desired == all tags active.
  - `int<nub>:debug:tags' for the user is non-nil AND matches one or more
     of the tags in TAGS.
    + Looking for a specific debug tag and found it.

If NIL-AS-WILDCARD is non-nil, `nil' for TAGS will be considered as
'is any debugging active?'.

If NIL-AS-WILDCARD is nil, `nil' for TAGS will be considered an error."
  (let ((func.name (int<nub>:format:callers "int<nub>:debug:active?"
                                            caller)))
    (int<nub>:user:exists? func.name user :error)

    (cond
     ;;------------------------------
     ;; [ERROR] Forgot to tag your debugging call!
     ;;------------------------------
     ((and (not nil-as-wildcard)
           (not tags))
      (int<nub>:error func.name
                      '(:newlines .
                        ("This debug message has not been tagged!"
                         "  user:   %S"
                         "  caller: %S"
                         "  tags:   %S"))
                      caller
                      user
                      tags))

     ;;------------------------------
     ;; Not Debugging -> Never.
     ;;------------------------------
     ;; Debugging disabled is always a "no".
     ((not (int<nub>:var:debugging user))
      nil)

     ;;------------------------------
     ;; Debugging -> Check Tags
     ;;------------------------------
     ;; If there are no tags for the user, then it is automatically a yes.
     ((not (int<nub>:var:debug:tags user))
      t)

     ;; If this is a general inquiry, then any tags for user is a yes at this point.
     ;; We've already checked that they are debugging in general.
     (nil-as-wildcard
      t)

     ;; The intersection of the sets `tags' and `int<nub>:debug:tags' will be
     ;; non-nil if any TAGS are active.
     (t
      (seq-intersection tags (int<nub>:var:debug:tags user))))))
;; (int<nub>:debug:active? :test<nub/output>::int<nub>:output "test" t)


;;------------------------------------------------------------------------------
;; Status
;;------------------------------------------------------------------------------

(defun int<nub>:debug:tags:sorted (tags)
  "Converts TAGS (list of keywords) into a sorted list of keyword strings."
  (cl-sort tags
           #'string-lessp
           :key (lambda (element) (downcase (symbol-name element)))))


(defun int<nub>:debug:status/message (user &optional tags)
  "Output debugging status and current debugging TAGS (list) for USER."
  (let ((func.name "int<nub>:debug:status/message"))
    (int<nub>:user:exists? func.name user :error)

    (let* ((tags/active          (int<nub>:debug:tags:sorted (int<nub>:var:debug:tags user)))
           (tags/input           (int<nub>:debug:tags:sorted tags))
           (tags/matched         (cl-sort (seq-intersection tags/active tags/input)
                                          #'string-lessp))
           (debugging            (int<nub>:var:debugging user))
           (debugging:tags/input (int<nub>:debug:active? user
                                                         func.name
                                                         tags
                                                         :nil-as-wildcard)))
      (message (int<nub>:format :newlines
                                "%s"
                                "  user:         %s"
                                "  debugging?:   %s"
                                "  active tags:  %s"
                                "  matched tags: %s")
               (if debugging:tags/input
                   ;; Debugging for specific tags?
                   (if (and tags/input tags/active)
                       "[DEBUG:tags(match)]"
                     "[DEBUG:GLOBAL]")
                 ;; Not debugging for tags; debugging in general?
                 (if debugging
                     "[debug:tags(miss)]"
                   "[----no----]"))

               user

               ;; What to display for all debugging tags depends on if debugging (for `nil' case).
               (if debugging
                   (if (null tags/active)
                       ;; `nil' here means 'debug everything'.
                       "ACTIVE globally -> (all debug output)"
                     tags/active)
                 ;; `nil' here doesn't mean much since debugging isn't active...
                 "inactive")

               (if tags/active
                   tags/active
                 "")

               (if (or debugging
                       tags/matched)
                   (if (null tags/matched)
                       ;; Can have no matches here; it means 'debug everything'.
                       "(no active tags -> all tag queries match)"
                     tags/matched)
                 ;; `nil' here doesn't mean much since debugging isn't active...
                 "none")))))


;;------------------------------------------------------------------------------
;; Commands: Debugging Status
;;------------------------------------------------------------------------------

(defun nub:debug/status (user)
  "Get message with status of debugging toggle, active debug tags."
  (interactive (int<nub>:prompt:user "nub:debug/status"
                                     "Debug Status for User"
                                     :list))
  ;; Valid user?
  (if user
      (int<nub>:debug:status/message user)
    (message "nub:debug/status: Unknown user: %S" user)))


;; TODO: Uncomment and finish from here...
;; ;;------------------------------------------------------------------------------
;; ;; Nub Debug API
;; ;;------------------------------------------------------------------------------

;; (defun nub:debug:debugging? (user &rest tags)
;;   "Get whether USER is currently debugging.

;; The answer depends on TAGS:
;;   - nil:
;;     - Returns just the debugging flag for USER.
;;   - non-nil:
;;     - Returns whether debugging is active for any of those TAGS for USER.
;;     - So 'am I debugging and for any of these tags?'."
;;   (interactive (int<nub>:prompt:user "nub:debug/status"
;;                                      "Debug Status for User"
;;                                      :list))
;;   (if tags
;;       ;; Passed in tags; make sure they're keywords.
;;       (seq-map #'int<nub>:normalize->keyword tags)

;;     ;; Else prompt for it.
;;     (setq tags (int<nub>:prompt:debug:tags "nub:debug:tag"
;;                                            "Tags to Check"
;;                                            user)))

;;   ;; They already got a message for invalid user, so just check for valid.
;;   (when user
;;     (int<nub>:debug:status/message user tags)))


;; (defun nub:debug:clear (user)
;;   "Turns off debugging for USER and clears all of USER's current debug tags."
;;   (interactive (int<nub>:prompt:user "nub:debug/toggle"
;;                                      "Toggle Debug for User"
;;                                      :list))
;;   (when user
;;     ;; Turn off debugging flag.
;;     (int<nub>:var:debugging:set user nil)

;;     ;; Wipe out the current active tags.
;;     (int<nub>:var:debug:tags:set user nil)

;;     ;; Display status.
;;     (int<nub>:debug:status/message user)))


;; ;;------------------------------------------------------------------------------
;; ;; Commands: Debugging Toggle
;; ;;------------------------------------------------------------------------------

;; (defun nub:debug/toggle (user)
;;   "Toggle debugging for the USER."
;;   (interactive (int<nub>:prompt:user "nub:debug/toggle"
;;                                      "Toggle Debug for User"
;;                                      :list))
;;   (when user
;;     ;; Toggle debug flag and display status after toggle.
;;     (int<nub>:var:debugging:set user :toggle)
;;     (int<nub>:debug:status/message user)))


;; ;;------------------------------------------------------------------------------
;; ;; Commands: Debugging Tags
;; ;;------------------------------------------------------------------------------

;; (defvar int<nub>:history:debug:tag nil
;;   "History variable for the debug tags of the `nub:debug/toggle' command.")


;; (defun nub:debug:tag (user &optional tag)
;;   "Toggle a debugging keyword TAG for the USER."
;;   (interactive (int<nub>:prompt:user "nub:debug:tag"
;;                                      "Toggle for Debug User"
;;                                      :list))
;;   (if tag
;;       ;; Passed in a tag; make sure it's a keyword.
;;       (int<nub>:normalize->keyword tag)
;;     ;; Else prompt for it.
;;     (setq tag (int<nub>:prompt:debug:tag "nub:debug:tag"
;;                                          "Toggle Debug Tag"
;;                                          user)))

;;   (if (or (not user)
;;           (not tag))
;;       (message (int<nub>:format :newlines
;;                                 "Cannot toggle tag without user and tag."
;;                                 "  user: %S"
;;                                 "  tag:  %S")
;;                user tag)

;;     ;; Toggle in/out of the active tags.
;;     (if (int<nub>:var:debug:tag:set user tag :toggle)
;;           ;; Toggled it on.
;;           (message (int<nub>:format :newlines
;;                                     "nub: Added debug tag: %S"
;;                                     "  user: %S"
;;                                     "  tags: %S")
;;                    tag
;;                    user
;;                    (int<nub>:var:debug:tags user))

;;         ;; Toggled it off.
;;         (message (int<nub>:format :newlines
;;                                   "nub: Removed debug tag: %S"
;;                                   "  user: %S"
;;                                   "  tags: %S")
;;                  tag
;;                  user
;;                  (int<nub>:var:debug:tags user)))))


;; (defun nub:debug/tag:clear (user)
;;   "Reset USER's debugging tags to nil."
;;   (interactive (int<nub>:prompt:user "nub:debug/tag:clear"
;;                                      "Debug User to Clear"
;;                                      :list))
;;   (when user
;;     (int<nub>:var:debug:tags user nil)
;;     (message "User '%s' cleared all debug tags: %S"
;;              user
;;              (int<nub>:var:debug:tags user))))


;; ;;------------------------------------------------------------------------------
;; ;; String Functions (message, fills)
;; ;;------------------------------------------------------------------------------

;; (defun int<nub>:debug:fill/clear ()
;;   "Setup fills for debug messages."
;;   (setq int<nub>:debug:fills/index 0))


;; (defun int<nub>:debug:fill (len)
;;   "CREATE a string of length LEN using next fill string as determined by
;; `int<nub>:debug:fills' and `int<nub>:debug:fills/index'."
;;   ;; Ensure string is proper length.
;;   (truncate-string-to-width
;;    (let* ((fill-str (elt int<nub>:debug:fills int<nub>:debug:fills/index))
;;           (fill-len (length fill-str))
;;           (times (1+ (/ len fill-len))) ; +1 for int math divide flooring odds.
;;           fill-list)
;;      ;; Create the filling from our "whatever width you want" strings by making a long-enough list of the fills.
;;      (while (> times 0)
;;        (setq fill-list (cons fill-str fill-list))
;;        ;; Loop conditional.
;;        (setq times (1- times)))

;;      ;; Update index for next time.
;;      (setq int<nub>:debug:fills/index (% (1+ int<nub>:debug:fills/index)
;;                                          (length int<nub>:debug:fills)))
;;      ;; Have long-enough list - convert to a string.
;;      (apply #'concat fill-list))
;;    len))
;; ;; (int<nub>:debug:fill 41)
;; ;; (int<nub>:debug:fill 42)
;; ;; (length (int<nub>:debug:fill 41))
;; ;; (length (int<nub>:debug:fill 42))


;; ;;------------------------------------------------------------------------------
;; ;; Debugging Functions
;; ;;------------------------------------------------------------------------------

;; (defmacro int<nub>:debug/message? (user caller tags message? msg &rest args)
;;   "Print out a debug message or `message'.

;; Will only evaluate CALLER, MSG, and ARGS when if MESSAGE? is non-nil or
;; if debugging.

;; If MESSAGE? is non-nil, always prints message. Otherwise only
;; prints if debugging (`int<nub>:var:debugging') and if any tag in
;; TAGS matches USER's active debugging tags (`int<nub>:debug:tags').

;; CALLER should be the calling function's name (string).

;; MSG should be the `message' formatting string.

;; ARGS should be the `message' arguments."
;;   (declare (indent 4))
;;   `(let ((int<nub>:macro:user ,user)
;;          (int<nub>:macro:tags ,tags))
;;      (int<nub>:user:exists? "int<nub>:debug/message?" int<nub>:macro:user :error)

;;      ;; Check with `int<nub>:debug:active?' first so that missing debug tags always error.
;;      (cond
;;       ;; Only message (at debug level) if passed checks.
;;       ((int<nub>:debug:active? int<nub>:macro:user int<nub>:macro:tags)
;;        (int<nub>:output user :debug ,caller ,msg ,@args))

;;       ;; Always message (at debug level) - regardless of debugging toggle/flags.
;;       (,message?
;;        (int<nub>:output user :debug ,caller ,msg ,@args))

;;       ;; Not debugging and not allowing message through otherwise.
;;       (t
;;        nil))))


;; (defmacro int<nub>:debug (user caller tags msg &rest args)
;;   "Print out a debug message.

;; Will only evaluate MSG, and ARGS when debugging.

;; Only prints if debugging (`int<nub>:var:debugging') and if any tag in TAGS
;; matches USER's active debugging tags (`int<nub>:debug:tags').

;; CALLER should be the calling function's name (string).

;; MSG should be the `message' formatting string.

;; ARGS should be the `message' arguments."
;;   (declare (indent 3))

;;   `(let* ((int<nub>:macro:user      ,user)
;;           (int<nub>:macro:caller    ,caller)
;;           (int<nub>:macro:func.name (int<nub>:format:callers "int<nub>:debug"
;;                                                              int<nub>:macro:caller)))
;;      (int<nub>:user:exists? int<nub>:macro:func.name
;;                             int<nub>:macro:user
;;                             :error)

;;      (when (int<nub>:debug:active? int<nub>:macro:user
;;                                    int<nub>:macro:func.name
;;                                    ,tags)
;;        (int<nub>:output int<nub>:macro:user
;;                         :debug
;;                         int<nub>:macro:caller
;;                         ,msg
;;                         ,@args))))
;; ;; Make sure it only evals args when debugging:
;; ;; (int<nub>:debug :default "test-func" nil (message "test"))
;; ;; (int<nub>:debug :default "test-func" '(:derive) (message "test"))
;; ;; (int<nub>:debug :default "test-func" '(:jeff) (message "test"))
;; ;; (let ((caller "test-func")
;; ;;       (tags '(:derive))
;; ;;       (msg "test message"))
;; ;;   (int<nub>:debug caller tags msg))


;; (defun int<nub>:debug:func (user debug/name debug/tags start-or-end &rest value)
;;   "Print out start/end function message, with optional VALUE.

;; Prints start message when START-OR-END is `:start'.
;; Prints end message w/ optional return value when START-OR-END is `:end'.

;; VALUEs are optional and should be:
;;   - nil
;;   - `cons' pairs of: '(name . value)"
;;   (declare (indent 3))
;;   (int<nub>:user:exists? "int<nub>:debug:func" user :error)

;;   (let ((func/name "int<nub>:debug:func")
;;         value/formatted)

;;     ;;------------------------------
;;     ;; Error checks.
;;     ;;------------------------------
;;     (unless (memq start-or-end '(:start :end))
;;       (int<nub>:error func/name
;;                       '(:newlines .
;;                         ("START-OR-END must be one of: %S; got: %S."
;;                          "  user:         %S"
;;                          "  debug/name:   %S"
;;                          "  debug/tags:   %S"
;;                          "  start-or-end: %S"
;;                          "  value:        %S"))
;;                       '(:start :end)
;;                       start-or-end
;;                       user
;;                       debug/name
;;                       debug/tags
;;                       start-or-end
;;                       value))

;;     ;;------------------------------
;;     ;; Format output.
;;     ;;------------------------------
;;     ;; No value alist - no output string.
;;     (cond ((not value)
;;            (setq value/formatted ""))

;;           ;; Invalid value alist - error out.
;;           ((not (int<nub>:alist:alist? value))
;;            (int<nub>:error func/name
;;                            '(:newlines .
;;                              ("VALUE is invalid for `%S'! Expecting `&rest VALUE' to be an alist. Got: %S"
;;                               "  user:         %S"
;;                               "  debug/name:   %S"
;;                               "  debug/tags:   %S"
;;                               "  start-or-end: %S"
;;                               "  value:        %S"))
;;                            start-or-end
;;                            value
;;                            user
;;                            debug/name
;;                            debug/tags
;;                            start-or-end
;;                            value))

;;           ;; Format nicely into columns.
;;           (t
;;            (let ((width/name 0)
;;                  values/print
;;                  fmt)
;;              ;; Convert names to strings, figure out print formatting.
;;              (dolist (input value)
;;                (let ((key (car input))
;;                      (value (cdr input)))
;;                  (if (eq :title key)
;;                      ;; Just push the title string.
;;                      (push (cons value "") values/print)
;;                    ;; Push formatted (to-string'd) key and value.
;;                    (let ((key/formatted (format "    %s:" key)))
;;                      (push (cons key/formatted value) values/print)
;;                      (setq width/name (max (length key/formatted)
;;                                            width/name))))))
;;              ;; ":" separator already provided above.
;;              (setq fmt (concat "%-" (number-to-string width/name) "s %S\n"))

;;              ;; Convert alist of strings to a single string.
;;              (dolist (input (nreverse values/print))
;;                (setq value/formatted (concat value/formatted
;;                                              (format fmt (car input) (cdr input))))))))

;;     ;;------------------------------
;;     ;; Start-of-function messages.
;;     ;;------------------------------
;;     (cond ((and (null value/formatted)
;;                 (eq :start start-or-end))
;;            (int<nub>:debug
;;                user
;;                debug/name
;;                debug/tags
;;              '("\n"
;;                "---[BEGIN]------>\n")))

;;           ;; VALUE exists and is valid; print it too.
;;           ((eq :start start-or-end)
;;            ;; Print start w/ input vars.
;;            (int<nub>:debug
;;                user
;;                debug/name
;;                debug/tags
;;              '("\n"
;;                "---[BEGIN]------>\n"
;;                "  ---[INPUTS]--->\n"
;;                "%s")
;;              value/formatted))

;;           ;;------------------------------
;;           ;; End-of-function messages.
;;           ;;------------------------------
;;           ;; No value provided; just print end.
;;           ((and (null value/formatted)
;;                 (eq :end start-or-end))
;;            (int<nub>:debug
;;                user
;;                debug/name
;;                debug/tags
;;              '("\n"
;;                "<--[END]-------\n")))

;;           ;; `:end' + VALUE; print end w/ return VALUE.
;;           ((eq :end start-or-end)
;;            (int<nub>:debug
;;                user
;;                debug/name
;;                debug/tags
;;              '("\n"
;;                "<--[END]-------\n"
;;                "  <--[RETURN]--\n"
;;                "%s")
;;              value/formatted))

;;           ;;------------------------------
;;           ;; Error: Bad START-OR-END
;;           ;;------------------------------
;;           (t
;;            (int<nub>:error func/name
;;                            '(:newlines .
;;                              ("Invalid start/end tag! Must be one of: %S; got: %S."
;;                               "  user:       %S"
;;                               "  debug/name: %S"
;;                               "  debug/tags: %S"
;;                               "  value:      %S"
;;                               "  value/formatted:"
;;                               "%S"))
;;                            '(:start :end)
;;                            start-or-end
;;                            user
;;                            debug/name
;;                            debug/tags
;;                            value
;;                            value/formatted)))))


;; ;;------------------------------------------------------------------------------
;; ;; The End.
;; ;;------------------------------------------------------------------------------
;; (imp:provide :nub 'debug)
