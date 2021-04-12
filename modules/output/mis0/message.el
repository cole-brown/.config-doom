;;; mis0/init/+message.el -*- lexical-binding: t; -*-

(-m//require 'internal 'mlist)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar -m//init/buffer (generate-new-buffer "mis0/init")
  "Buffer for mis0/init messages.")


;;------------------------------------------------------------------------------
;; Functions
;;------------------------------------------------------------------------------

(defun mis0/init/notify (message &rest args)
  "Output to `-m//init/buffer' and minibuffer."
  (minibuffer-message (apply #'mis0/init/message message args)))


(defun mis0/init/message (message &rest args)
  "Format MESSAGE and ARGS, append as new line in `-m//init/buffer'.
Returns formatted output."
  (with-current-buffer -m//init/buffer
    (let ((output (apply #'format message args)))
      (save-mark-and-excursion
        (goto-char (point-max))
        (insert "\n" output)
        )
      output)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; provide to mis0 and to everyone
(-m//provide 'message)
(provide 'mis0/message)
