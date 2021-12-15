;;; mis/message/message.el -*- lexical-binding: t; -*-

(imp:require :mis 'internal 'const)
(imp:require :mis 'internal 'valid)
(imp:require :mis 'internal 'mlist)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar int<mis>:init/buffer (generate-new-buffer "mis/init")
  "Buffer for mis/init messages.")


;;------------------------------------------------------------------------------
;; Functions
;;------------------------------------------------------------------------------

(defun mis:init/notify (message &rest args)
  "Output to `int<mis>:init/buffer' and minibuffer."
  (minibuffer-message (apply #'mis:init/message message args)))


(defun mis:init/message (message &rest args)
  "Format MESSAGE and ARGS, append as new line in `int<mis>:init/buffer'.
Returns formatted output."
  (with-current-buffer int<mis>:init/buffer
    (let ((output (apply #'format message args)))
      (save-mark-and-excursion
        (goto-char (point-max))
        (insert "\n" output)
        )
      output)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :mis 'message 'message)
