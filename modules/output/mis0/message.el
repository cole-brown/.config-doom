;;; mis0/init/message.el -*- lexical-binding: t; -*-

(-m//require 'internal 'mlist)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar -m//init/buffer.message "mis0:init:message"
  "Buffer name for mis0/init messages.")


(defvar -m//init/buffer.warning "mis0:init:warning"
  "Buffer name for mis0/init messages.")


(defvar -m//init/warnings nil
  "List of warning messages displayed via `mis0/init/warning'.")


;;------------------------------------------------------------------------------
;; Functions
;;------------------------------------------------------------------------------

(defun mis0/init/notify (message &rest args)
  "Output to `-m//init/buffer.message' and minibuffer."
  (minibuffer-message (apply #'mis0/init/message message args)))


(defun mis0/init/message (message &rest args)
  "Format MESSAGE and ARGS, append as new line in `-m//init/buffer.message'.
Returns formatted output."
  (with-current-buffer (get-buffer-create -m//init/buffer.message)
    (let ((output (apply #'format message args)))
      (save-mark-and-excursion
        (goto-char (point-max))
        (insert "\n" output)
        )
      output)))


(defun mis0/init/warning (function-name message-fmt &rest args)
  "Outputs a warning message to the mis0 buffer.

Format MESSAGE-FMT and ARGS like `mis0/init/message', but indented between
\"[WARNING `<FUNCTION-NAME>']\" and \"[/WARNING `<FUNCTION-NAME>']\" lines.

Also saves the formatted message to a list of warnings that can be displayed
when init is done, if desired."
  (with-current-buffer (get-buffer-create -m//init/buffer.message)
    ;;------------------------------
    ;; Output to mis/init buffer
    ;;------------------------------
    ;; Do the formatting of our params.
    (let* ((formatted (apply #'format message-fmt args))
           (indent (make-string 4 ?\s))
           ;; Combine lines back together with indentation.
           (output (mapconcat (lambda (line)
                                "Indent each line."
                                (concat indent line))
                              ;; Break into lines.
                              (split-string formatted "\n")
                              "\n")))
      (save-mark-and-excursion
        (goto-char (point-max))
        ;; Final line empty?
        (let* ((line/final/text (thing-at-point 'line 'no-properties))
               (line/final? (if (stringp line/final/text)
                                (string= (string-trim line/final/text) "")
                              nil)))
          ;; Previous line empty?
          (forward-line -1)
          (beginning-of-line)
          (let* ((line/prev/text (thing-at-point 'line 'no-properties))
                 (line/prev? (if (stringp line/prev/text)
                                 (string= (string-trim line/prev/text) "")
                               nil)))

            ;; Insert a blank line if there isn't one.
            (goto-char (point-max))
            (when (and (not line/prev?)
                       (not line/final?))
              (insert "\n\n"))))

        ;; Insert the warning block.
        (insert (format "[WARNING `%s']" function-name))
        (insert "\n"
                output)
        (insert "\n" (format "[/WARNING `%s']" function-name)))

      ;;------------------------------
      ;; Save to warnings list.
      ;;------------------------------
      ;; Saving the indented version since I want indented later too, at the moment.
      ;; But also add the function-name in there.
      (push (format "%s`%s':\n%s" indent function-name output)
            -m//init/warnings)

      ;; Return the message, in case they want it for something.
      formatted)))
;; (mis0/init/warning "test.func" "%s %S" "hello there" 'grevious)
;; (mis0/init/warning "test.func" "%s %S" "hello there\n" 'grevious)


(defun mis0/init/finalize/warnings (&optional pop-to-warnings)
  "Indicate to mis0 that start-up is complete.

If there are items in the `-m//init/warnings' list, this will print them
to the `-m//init/buffer.warning' buffer.

If POP-TO-WARNINGS is non-nil and there are items in the `-m//init/warnings'
list, this will pop to it (or pop it up)."
  (when -m//init/warnings
    (with-current-buffer (get-buffer-create -m//init/buffer.warning)
      (goto-char (point-max))
      (let ((num-warnings (length -m//init/warnings)))
        ;; Print info.
        (let* ((headline/text (format "  %d warning%s during start-up/init.  "
                                      num-warnings
                                      (if (/= 1 num-warnings)
                                          "s"
                                        "")))
               (headline/line  (make-string (length headline/text) ?─)))
          (insert headline/line
                  "\n"
                  headline/text
                  "\n"
                  headline/line))

      ;; Print in the order they were received.
      (dotimes (index num-warnings)
        (let* ((index/1-based (1+ index))
               (index/reverse (- num-warnings index/1-based)))
          (insert "\n\n"
                  (format "WARNING #%d:" index/1-based)
                  "\n"
                  (format "%s" (seq-elt -m//init/warnings index/reverse))))))

      (insert "\n")))

  (when (and -m//init/warnings
             pop-to-warnings)
    ;; NOTE: If you want to change the pop-up rules for this, wrap with:
    ;; (with-popup-rules! autogit:doom:popup-rules
    ;;    ...
    ;;    )
    (pop-to-buffer -m//init/buffer.warning)))
;; (mis0/init/finalize/warnings)
;; (mis0/init/finalize/warnings 'pop-to-it)


(defun mis0/init/complete (&optional pop-to-warnings)
  "Indicate to mis0 that start-up is complete.

This adds a transient hook to `doom-init-modules-hook' for showing any
init warnings.

If POP-TO-WARNINGS is non-nil and there are warnings, this will pop to
the warnings buffer when the hook runs."
  (run-at-time 5   ; Run this many seconds after we execute this.
               nil ; Do not repeat.
               ;; This function takes care of ignoring itself when there are no warnings.
               #'mis0/init/finalize/warnings
               pop-to-warnings))
;; (mis0/init/complete)
;; (mis0/init/complete 'pop-to-it)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; provide to mis0 and to everyone
(-m//provide 'message)
(provide 'mis0/message)
