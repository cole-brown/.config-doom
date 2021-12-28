;;; emacs/imp/+debug.el -*- lexical-binding: t; -*-

;;; Commentary:

;; Debugging functionality for imp.

;;------------------------------------------------------------------------------
;; Debugging Toggle
;;------------------------------------------------------------------------------

(defvar int<imp>:debug:flag nil
  "Debug flag.")


(defun imp:debug:toggle ()
  "Toggle debugging for imp."
  (interactive)
  (setq int<imp>:debug:flag (not int<imp>:debug:flag))
  (imp:debug:status (if int<imp>:debug:flag
                        "Enabled debug flag."
                      "Disabled debug flag.")))


(defun imp:debug:status (&optional msg)
  "Print debugging status for imp.

If MSG is non-nil, it is output just before the status but in the same
`message'."
  (interactive)

  (let* ((line "────────────────────────────────")
         (status (list "Debug Feature Flag:    %s"
                   "`int<imp>:debug:flag': %s"
                   line
                   " %s")))
    ;;---
    ;; Do we have a message?
    ;;---
    ;; Yes and it's a string - use as-is.
    (cond ((stringp msg)
           (push line status)
           (push msg status))

          ;; It's something else; formatted to a string.
          (msg
           (push line status)
           (push (format "%S" msg) status))

          ;; No msg, do nothing.
          (t
           nil))

    ;;---
    ;; Print status.
    ;;---
    (message (mapconcat #'identity
                        status
                        "\n")
             (if (featurep! +debug)
                 "[--SET--]"
               "[-------]")
             (if int<imp>:debug:flag
                 "[ENABLED]"
               "[-------]")
             (if (int<imp>:debug:enabled?)
                 "[ENABLED]"
               "[disabled]"))))
;; (imp:debug:status)
;; (imp:debug:status "Toggled a bit via solar radiation.")


;;------------------------------------------------------------------------------
;; Debugging Functions
;;------------------------------------------------------------------------------

(defun int<imp>:debug:enabled? ()
  "Returns true if one or more debug flags are enabled.

Flags:
  - `+debug' feature flag in `doom!' macro in user's \"<doom-dir>/init.el\".
  - `int<imp>:debugging' toggle variable."
  ;; Is a debug flag enabled?
  (cond
   ;; The `+debug' flag in the `doom!' macro in user's "<doom-dir>/init.el".
   ((featurep! +debug)
    t)

   ;; `:imp' debugging toggle:
   (int<imp>:debug:flag)

   ;; Fallthrough: debugging is not enabled.
   (t
    nil)))


(defun int<imp>:debug (caller string &rest args)
  "Print out a debug message if debugging is enabled.

CALLER should be the calling function's name.

STRING should be a string, which can have formatting info in it (see `format'),
and will be printed as the debug message.

ARGS should be args for formatting the STRING."
  (when (int<imp>:debug:enabled?)
    (apply #'message
           (concat "[   debug]: "
                   caller
                   ": "
                   string)
           args)))
;; (int<imp>:debug "test_func" "test")


(defun int<imp>:debug:newline ()
  "Prints an empty debug line if debugging."
  (when (int<imp>:debug:enabled?)
    (message " ")))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Don't provide. Imp internal only.
