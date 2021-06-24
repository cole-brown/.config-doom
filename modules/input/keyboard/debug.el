;;; input/keyboard/debug.el -*- lexical-binding: t; -*-

;;; Commentary:

;; Simple debugging functionality for layout.


;;------------------------------------------------------------------------------
;; Notes
;;------------------------------------------------------------------------------

;;------------------------------
;; Future Funcionality?
;;------------------------------
;;
;; Indentation levels?
;;   - Automatic based on call stack?
;;   - Manually based on an `input//kl:debug' parameter?


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar input//kl:debugging nil
  "Debug flag. Non-nil means debugging is active.")


(defvar input//kl:debug/tags nil
  "List of active debugging keyword tags. Any keyword matched in
the list will be printed out when debugging is active.

If there are no tags in the list, or the list is nil, everything
will be printed.")


(defvar input//kl:debug/tags/common
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


;;------------------------------------------------------------------------------
;; Commands: Debugging Status
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:debug/status ()
  "Get message with status of debugging toggle, active debug tags."
  (interactive)
  (message ":input/keyboard/layout module: %s\n  tags: %s"
           (if input//kl:debugging
               "[DEBUGGING]"
             "[disabled]")
           (if (null input//kl:debug/tags)
               "()"
             input//kl:debug/tags)))


;;------------------------------------------------------------------------------
;; Commands: Debugging Toggle
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:debug/toggle ()
  "Toggle debugging for ':input/keyboard/layout' module."
  (interactive)
  (setq input//kl:debugging (not input//kl:debugging))
  (message "input//kl:debugging: %s%s"
           (if input//kl:debugging
               "[ENABLED]"
             "[disabled]")
           (if input//kl:debugging
               (if (not input//kl:debug/tags)
                   " (all debug output)"
                 (format " with tags: %S" input//kl:debug/tags))
             "")))


;;------------------------------------------------------------------------------
;; Commands: Debugging Tags
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:debug/tag:toggle (tag)
  "Toggle a debugging keyword tag for ':input/keyboard/layout' module."
  (interactive (list (completing-read "Toggle Debug Tag: "
                                      input//kl:debug/tags/common
                                      nil
                                      'confirm)))
  ;; Convert to keyword.
  (let ((keyword (input//kl:normalize->keyword tag)))
    ;; Toggle in/out of the active tags.
    (if (memq keyword input//kl:debug/tags)
        (prog1
            (setq input//kl:debug/tags (remove keyword input//kl:debug/tags))
          (message "':input/keyboard/layout' removed debug tag: %S\n  tags: %S"
                   keyword input//kl:debug/tags))
      (prog1
          (push keyword input//kl:debug/tags)
        (message "':input/keyboard/layout' added debug tag: %S\n  tags: %S"
                 keyword input//kl:debug/tags)))))


(defun input:keyboard/layout:debug/tag:clear ()
  "Reset debugging tags to nil."
  (interactive)
  (setq input//kl:debug/tags nil)
  (message "':input/keyboard/layout' cleared debug tags.\n  tags: %S"
           input//kl:debug/tags))


;;------------------------------------------------------------------------------
;; Debugging Functions
;;------------------------------------------------------------------------------

(defun input//kl:debug:tagged (tags)
  "Returns non-nil if one of the keywords in TAGS list is an active debugging tag."
  ;; If there are no `input//kl:debug/tags', then it is automatically a yes.
  (cond ((not input//kl:debug/tags)
         t)

        ;; Should no `tags' also be automatic yes?
        ((not tags)
         t)

        ;; The intersection of the sets `tags' and `input//kl:debug/tags' will be
        ;; non-nil if any TAGS are active.
        (t
         (seq-intersection tags input//kl:debug/tags))))


(defun input//kl:debugging? (tags)
  "Returns non-nil if `input//kl:debugging' is active and tags match enabled tags."
  (and input//kl:debugging
       (input//kl:debug:tagged tags)))


(defun input//kl:debug:message (func msg args-list)
  "Returns a sexpr for creating a debug `message'.

FUNC should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS-LIST should be the `message' arguments."
  `(message
    (concat ,func ": " ,msg)
    ,@args-list))


(defmacro input//kl:debug (func tags msg &rest args)
  "Print out a debug message.

Will only evaluate FUNC, MSG, and ARGS when debugging.

Only prints if debugging (`input//kl:debugging') and if any tag in TAGS
matches active debugging tags (`input//kl:debug/tags').

FUNC should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS should be the `message' arguments."
  (declare (indent 2))

  `(when (input//kl:debugging? ,tags)
    ;; (ignore func msg args)))
    ,(input//kl:debug:message func msg args)))
;; Make sure it only evals args when debugging:
;; (input//kl:debug "test-func" nil (message "test"))
;; (input//kl:debug "test-func" '(:derive) (message "test"))
;; (input//kl:debug "test-func" '(:jeff) (message "test"))
;; (let ((func "test-func")
;;       (tags '(:derive))
;;       (msg "test message"))
;;   (input//kl:debug func tags msg))


(defmacro input//kl:debug-or-message (func tags message? msg &rest args)
  "Print out a debug message or `message'.

Will only evaluate FUNC, MSG, and ARGS when if MESSAGE? is non-nil or
if debugging.

If MESSAGE? is non-nil, always prints message. Otherwise only
prints if debugging (`input//kl:debugging') and if any tag in
TAGS matches active debugging tags (`input//kl:debug/tags').

FUNC should be the calling function's name (string).

MSG should be the `message' formatting string.

ARGS should be the `message' arguments."
  (declare (indent 3))
  `(if ,message?
      ;; Just message.
      ,(input//kl:debug:message func msg args)
    ;; Debug checks, then message.
    (when (and input//kl:debugging
               (input//kl:debug:tagged ,tags))
      ,(input//kl:debug:message func msg args))))
;; (input//kl:debug-or-message "test-func" '(:jeff) nil (message "test"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------


;; TODO: replace:
;; (message
;; (input//kl:debug "input//kl:layout:TODO-FUNC"
;;                  '(TODO-TAGS)
