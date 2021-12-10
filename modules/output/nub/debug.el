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


;; TODO: all nub commands: remove '/'?

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

(defun int<nub>:debug:tags:verify (caller user tags &optional error?)
  "Returns non-nil if TAGS are 'correct'.

Correct, currently, means that TAGS is:
  - a list containing only keywords

Returns TAGS if TAGS are valid.
If tags are not valid:
  If ERROR? is non-nil, signals an error.
  Else returns nil."
  (let ((func.name (int<nub>:format:callers "int<nub>:debug:tags:verify"
                                            caller)))
    (int<nub>:user:exists? func.name user :error)

    (cond ((null tags)
           (if error?
               (int<nub>:error func.name
                               '(:newlines .
                                 ("This debug message has not been tagged!"
                                  "  user:   %S"
                                  "  caller: %S"
                                  "  tags:   %S"))
                               caller
                               user
                               tags)
             nil))

          ((not (listp tags))
           (if error?
               (int<nub>:error func.name
                               '(:newlines .
                                 ("Debug message's tags are not a list?"
                                  "  user:   %S"
                                  "  caller: %S"
                                  "  tags:   %S"))
                               caller
                               user
                               tags)
             nil))

          ((not (seq-every-p #'keywordp tags))
           (if error?
               (int<nub>:error func.name
                               '(:newlines .
                                 ("Debug message's tags must all be keywords!"
                                  "  user:   %S"
                                  "  caller: %S"
                                  "  tags:   %S"))
                               caller
                               user
                               tags)
             nil))

          ;;------------------------------
          ;; Success: Ran out of error checks.
          ;;------------------------------
          (t
           tags))))


(defun int<nub>:debug:active? (caller user tags)
  "Returns non-nil if USER is currently debugging for anything in the
list of TAGS.

CALLER should be calling function's string name.

Debugging when `int<nub>:var:debugging' is non-nil for USER and one of these
is true:
  - `int<nub>:var:debug:tags' for the user is nil
    + No specific debugging tags desired == all tags active.
(progn

  - `int<nub>:var:debug:tags' for the user is non-nil AND matches one or more
     of the tags in TAGS.
    + Looking for a specific debug tag and found it."
  (let* ((func.name (int<nub>:format:callers "int<nub>:debug:active?"
                                             caller))
         (tags/input tags)
         (tags/active (int<nub>:var:debug:tags user))
         (tags/matched (seq-intersection tags/input tags/active)))
    (int<nub>:user:exists? func.name user :error)

    (cond
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

     ;; If use is debugging for specific tags, but TAGS is nil, it is also a yes.
     ;; Return something other than `t' in case this case should be checked?
     ((null tags/input)
      ;; Try returning active tags? If that's not good, return `:tags/other' or something.
      tags/active)

     ;; The intersection of the sets `tags' and `int<nub>:var:debug:tags' will be
     ;; non-nil if any TAGS are active.
     (t
      tags/matched))))
;; (int<nub>:debug:active? "test" test<nub>:user '(:testing))


;;------------------------------------------------------------------------------
;; Status
;;------------------------------------------------------------------------------

(defun int<nub>:debug:tags:sorted (tags)
  "Converts TAGS (list of keywords) into a sorted list of keyword strings."
  (cl-sort tags
           #'string-lessp
           :key (lambda (element) (downcase (symbol-name element)))))


(defun int<nub>:debug:status/message (prefix user &optional tags)
  "Output debugging status and current debugging TAGS (list) for USER."
  (let ((func.name "int<nub>:debug:status/message"))
    (int<nub>:user:exists? func.name user :error)

    (let* ((tags/active      (int<nub>:debug:tags:sorted (int<nub>:var:debug:tags user)))
           (debugging        (int<nub>:var:debugging user))
           (debugging:active (int<nub>:debug:active? func.name
                                                     user
                                                     tags)))
      (message (int<nub>:format :newlines
                                "%s  %s"
                                "    user:         %s"
                                "    debugging?:   %s"
                                "    desired tags: %s"
                                "    active tags:  %s"
                                "    matched tags: %s")
               ;;---
               ;; Prefix: On its own line or does not exist.
               ;;---
               (if prefix
                   (concat prefix "\n")
                 "")

               ;;---
               ;; Debug Status summary:
               ;;---
               (if debugging:active
                   ;; Debugging for specific tags?
                   (if (listp debugging:active)
                       "[DEBUG:tags(match)]"
                     "[DEBUG:GLOBAL]")
                 ;; Not debugging for tags; debugging in general?
                 (if debugging
                     "[debug:tags(miss)]"
                   "[----off----]"))

               ;;---
               ;; User Keyword
               ;;---
               user

               ;;---
               ;; Debug Flag/Tags Summary
               ;;---
               ;; What to display for all debugging tags depends on if debugging (for `nil' case).
               (if debugging
                   (if (null tags/active)
                       ;; `nil' here means 'debug everything'.
                       "ACTIVE globally -> (all debug output)"
                     ;; Debugging for these tags
                     (format "ACTIVE for: %S -> (must match for debug output)" tags/active))
                 ;; `nil' here doesn't mean much since debugging isn't active...
                 "inactive")

               ;;---
               ;; Tags: Desired/Requested
               ;;---
               tags

               ;;---
               ;; Tags: All Active
               ;;---
               (if tags/active
                   tags/active
                 "")

               ;;---
               ;; Tags: Matches
               ;;---
               (cond ((listp debugging:active)
                      ;; Show the matched tags.
                      debugging:active)

                     ;; Debugging but no matches == 'debug everything'.
                     ((eq debugging:active t)
                      "(no active tags -> all tag queries match)")

                     ;; `debugging:active' == nil; not debugging.
                     (t
                      "none")))

      ;; Return matched debug tags, t if global debugging, or nil if not debugging.
      debugging:active)))


;;------------------------------------------------------------------------------
;; COMMANDS: Debugging Status
;;------------------------------------------------------------------------------

(defun nub:debug:status (user)
  "Get message with status of debugging toggle, active debug tags."
  (interactive (int<nub>:prompt:user "nub:debug:status"
                                     "Debug Status for User"
                                     :list))
  ;; Valid user?
  (if user
      ;; This also returns active tags, t, or nil.
      (int<nub>:debug:status/message (format "Nub Debug Status: %S" user)
                                     user)

    (message "nub:debug:status: Unknown user: %S" user)
    ;; Let's just say 'not debugging' for unknown user.
    nil))


;;------------------------------------------------------------------------------
;; COMMANDS: Nub Debugging
;;------------------------------------------------------------------------------

(defun nub:debug:debugging? (user &rest tags)
  "Get whether USER is currently debugging.

TAGS will be flattened before being checked.

The answer depends on TAGS:
  - nil:
    - Returns just the debugging flag for USER.
  - non-nil:
    - Returns whether debugging is active for any of those TAGS for USER.
    - So 'am I debugging and for any of these tags?'."
  (interactive (int<nub>:prompt:user "nub:debug:debugging?"
                                     "Debug Status for User"
                                     :list))
  (let ((func.name "nub:debug:debugging?"))
    (setq tags (if tags
                   ;; Passed in tags; make sure they're keywords.
                   (seq-map #'int<nub>:normalize->keyword (flatten-list tags))
                 ;; Else prompt for it.
                 (int<nub>:prompt:debug:tags func.name
                                             "Tags to Check"
                                             user)))

    (if user
        ;; This also returns active tags, t, or nil.
        (int<nub>:debug:status/message (format "Nub Debugging?: %S" user)
                                       user tags)
      (message "%s: Unknown user: %S" func.name user)
      ;; Let's just say 'not debugging' for unknown user.
      nil)))



(defun nub:debug:clear (user)
  "Turns off debugging for USER and clears all of USER's current debug tags."
  (interactive (int<nub>:prompt:user "nub:debug:clear"
                                     "Toggle Debug for User"
                                     :list))
  (let ((func.name "nub:debug:clear"))
    (if (not user)
        (progn
          (message "%s: Unknown user: %S" func.name user)
          ;; Let's just say 'not debugging' for unknown user.
          nil)

      ;; Turn off debugging flag.
      (int<nub>:var:debugging:set user nil)

      ;; Wipe out the current active tags.
      (int<nub>:var:debug:tags:set user nil)

      ;; Display status.
      (message "Nub: Cleared debug flags: %S" user)
      ;; This also returns active tags, t, or nil.
      (int<nub>:debug:status/message (format "Debug Status: %S" user)
                                     user))))


;;------------------------------------------------------------------------------
;; COMMANDS: Debugging Toggle
;;------------------------------------------------------------------------------

(defun nub:debug:toggle (user)
  "Toggle debugging for the USER."
  (interactive (int<nub>:prompt:user "nub:debug:toggle"
                                     "Toggle Debug for User"
                                     :list))
  (if (not user)
      (progn
        (message "%s: Unknown user: %S" func.name user)
        ;; Let's just say 'not debugging' for unknown user.
        nil)

    ;; Toggle debug flag and display status after toggle.
    (int<nub>:var:debugging:set user :toggle)

    ;; This also returns active tags, t, or nil.
    (int<nub>:debug:status/message (format "Nub: Toggled Debugging: %S" user)
                                   user)))


;;------------------------------------------------------------------------------
;; COMMANDS: Debugging Tags
;;------------------------------------------------------------------------------

(defvar int<nub>:history:debug:tag nil
  "History variable for the debug tags of the `nub:debug:tag' command.")


(defun nub:debug:tag (user &optional tag)
  "Toggle a debugging keyword TAG for the USER."
  (interactive (int<nub>:prompt:user "nub:debug:tag"
                                     "Toggle for Debug User"
                                     :list))

  (let ((func.name "nub:debug:tag")
        status.prefix)
    (if tag
        ;; Passed in a tag; make sure it's a keyword.
        (int<nub>:normalize->keyword tag)
      ;; Else prompt for it.
      (setq tag (int<nub>:prompt:debug:tag func.name
                                           "Toggle Debug Tag"
                                           user)))

    (if (or (not user)
            (not tag))
        (progn
          (message (int<nub>:format :newlines
                                    "Cannot toggle tag without user and tag."
                                    "  user: %S"
                                    "  tag:  %S")
                   user tag)
          nil)

      ;; Toggle in/out of the active tags.
      (if (int<nub>:var:debug:tag:set user tag :toggle)
          ;; Toggled it on.
          (setq status.prefix (format "nub: Added debug tag: %S"
                                      tag))

        ;; Toggled it off.
        (setq status.prefix (format "nub: Removed debug tag: %S"
                                    tag)))

      ;; This also returns active tags, t, or nil.
      (int<nub>:debug:status/message status.prefix
                                     user))))


(defun nub:debug:tag/clear (user)
  "Reset USER's debugging tags to nil."
  (interactive (int<nub>:prompt:user "nub:debug:tag/clear"
                                     "Debug User to Clear"
                                     :list))
  (if (not user)
      (progn
        (message "%s: Unknown user: %S" func.name user)
        nil)

    (int<nub>:var:debug:tags user nil)
    ;; This also returns active tags, t, or nil.
    (int<nub>:debug:status/message (format "nub: Cleared all debug tags: %S" user)
                                   user)))


;;------------------------------------------------------------------------------
;; Debug Output
;;------------------------------------------------------------------------------

(defun int<nub>:debug:func (caller user func/name func/tags start-or-end value)
  "Print out start/end function message, with optional VALUE.

Prints start message when START-OR-END is `:start'.
Prints end message w/ optional return value when START-OR-END is `:end'.

VALUEs are optional and should be:
  - nil
  - `cons' pairs of: '(name . value)"
    (let ((callers (int<nub>:format:callers "int<nub>:debug:func" caller))
        value/formatted)
      (int<nub>:user:exists? callers user :error)
      (int<nub>:debug:tags:verify callers
                                  func/tags
                                  :error)

    ;;------------------------------
    ;; Error checks.
    ;;------------------------------
    (unless (memq start-or-end '(:start :end))
      (int<nub>:error callers
                      '(:newlines .
                        ("START-OR-END must be one of: %S; got: %S."
                         "  user:         %S"
                         "  func/name:    %S"
                         "  func/tags:    %S"
                         "  start-or-end: %S"
                         "  value:        %S"))
                      '(:start :end)
                      start-or-end
                      user
                      func/name
                      func/tags
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
           (int<nub>:error callers
                           '(:newlines .
                             ("VALUE is invalid for `%S'! Expecting `&rest VALUE' to be an alist. Got: %S"
                              "  user:         %S"
                              "  func/name:    %S"
                              "  func/tags:    %S"
                              "  start-or-end: %S"
                              "  value:        %S"))
                           start-or-end
                           value
                           user
                           func/name
                           func/tags
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
           (nub:debug
               user
               func/name
               func/tags
             '("\n"
               "---[BEGIN]------>\n")))

          ;; VALUE exists and is valid; print it too.
          ((eq :start start-or-end)
           ;; Print start w/ input vars.
           (nub:debug
               user
               func/name
               func/tags
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
           (nub:debug
               user
               func/name
               func/tags
             '("\n"
               "<--[END]-------\n")))

          ;; `:end' + VALUE; print end w/ return VALUE.
          ((eq :end start-or-end)
           (nub:debug
               user
               func/name
               func/tags
             '("\n"
               "<--[END]-------\n"
               "  <--[RETURN]--\n"
               "%s")
             value/formatted))

          ;;------------------------------
          ;; Error: Bad START-OR-END
          ;;------------------------------
          (t
           (int<nub>:error callers
                           '(:newlines .
                             ("Invalid start/end tag! Must be one of: %S; got: %S."
                              "  user:      %S"
                              "  func/name: %S"
                              "  func/tags: %S"
                              "  value:     %S"
                              "  value/formatted:"
                              "%S"))
                           '(:start :end)
                           start-or-end
                           user
                           func/name
                           func/tags
                           value
                           value/formatted)))))


;;------------------------------------------------------------------------------
;; API: Debug Messages
;;------------------------------------------------------------------------------

(defmacro nub:debug (user caller tags msg &rest args)
  "Print out a debug message.

Will only evaluate MSG, and ARGS when debugging.

Only prints if debugging (`int<nub>:var:debugging') and if any tag in TAGS
matches USER's active debugging tags (`int<nub>:var:debug:tags').

CALLER should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS should be the `message' arguments."
  (declare (indent 3))

  `(let* ((int<nub>:macro:user      ,user)
          (int<nub>:macro:tags      ,tags)
          (int<nub>:macro:caller    ,caller)
          (int<nub>:macro:func.name (int<nub>:format:callers "nub:debug"
                                                             int<nub>:macro:caller)))
     (int<nub>:user:exists? int<nub>:macro:func.name
                            int<nub>:macro:user
                            :error)
     (int<nub>:debug:tags:verify int<nub>:macro:func.name
                                 int<nub>:macro:tags
                                 :error)

     (when (int<nub>:debug:active? int<nub>:macro:func.name
                                   int<nub>:macro:user
                                   int<nub>:macro:tags)
       (int<nub>:output int<nub>:macro:user
                        :debug
                        int<nub>:macro:caller
                        ,msg
                        ,@args))))
;; Make sure it only evals args when debugging:
;; (nub:debug :default "test-func" nil (message "test"))
;; (nub:debug :default "test-func" '(:derive) (message "test"))
;; (nub:debug :default "test-func" '(:jeff) (message "test"))
;; (let ((caller "test-func")
;;       (tags '(:derive))
;;       (msg "test message"))
;;   (nub:debug caller tags msg))


(defmacro nub:debug-or-message (user caller tags message? msg &rest args)
  "Print out a debug message or just a `message'.

Will only evaluate CALLER, MSG, and ARGS when if MESSAGE? is non-nil or
if debugging.

If MESSAGE? is non-nil, always prints message. Otherwise only
prints if USER is debugging and if any tag in TAGS matches USER's active
debugging tags.

CALLER should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS should be the `message' arguments."
  (declare (indent 4))
  `(let ((int<nub>:macro:user      ,user)
         (int<nub>:macro:tags      ,tags)
         (int<nub>:macro:caller    ,caller)
         (int<nub>:macro:func.name (int<nub>:format:callers "nub:debug"
                                                            int<nub>:macro:caller)))
     (int<nub>:user:exists? int<nub>:macro:func.name
                            int<nub>:macro:user
                            :error)
     (int<nub>:debug:tags:verify int<nub>:macro:func.name
                                 int<nub>:macro:tags
                                 :error)

     ;; Check with `int<nub>:debug:active?' first so that missing debug tags always error.
     (cond
      ;; Only message (at debug level) if passed checks.
      ((int<nub>:debug:active? int<nub>:macro:func.name
                               int<nub>:macro:user
                               int<nub>:macro:tags)
       (int<nub>:output user
                        :debug
                        int<nub>:macro:caller
                        ,msg
                        ,@args))

      ;; Always message (at debug level) - regardless of debugging toggle/flags.
      (,message?
       (int<nub>:output user
                        :debug
                        int<nub>:macro:caller
                        ,msg
                        ,@args))

      ;; Not debugging and not allowing message through otherwise.
      (t
       nil))))


(defun nub:debug:func/start (user func/name func/tags &rest value)
  "Print out start-of-function message, with optional VALUEs.

VALUEs are optional and should be:
  - nil
  - `cons' pairs of: '(name . value)
    + Intended for input params."
  (int<nub>:debug:func "nub:debug:func/start"
    user
    func/name
    func/tags
    :start
    value))


(defun nub:debug:func/end (user func/name func/tags &rest value)
  "Print out end-of-function message, with optional VALUEs.

VALUEs are optional and should be:
  - nil
  - `cons' pairs of: '(name . value)
    + Intended for input params."
  (int<nub>:debug:func "nub:debug:func/end"
    user
    func/name
    func/tags
    :end
    value))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub 'debug)
