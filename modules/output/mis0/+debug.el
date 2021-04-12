;;; mis/internal/+debug.el -*- lexical-binding: t; -*-

;;; Commentary:

;; Debugging functionality for mis.

;;------------------------------------------------------------------------------
;; Debugging Toggle
;;------------------------------------------------------------------------------

(defvar mis//debugging nil
  "Debug flag.")


(defun mis//debug/toggle ()
  "Toggle debugging for mis."
  (interactive)
  (setq mis//debugging (not mis//debugging))
  (message "mis//debugging: %s"
           (if mis//debugging
               "enabled"
             "disabled")))


;;------------------------------------------------------------------------------
;; Debugging Functions
;;------------------------------------------------------------------------------

(defun mis//debug (func msg &rest args)
  "Print out a debug message if debugging."
  (when mis//debugging
    (apply #'message
           (concat func ": " msg)
           args)))
;; (mis//debug "test_func" "test")


(defmacro mis//when-debugging (&rest body)
  "Only run BODY when debug flag is set."
  (declare (indent defun))
  `(when mis//debugging
     ,@body))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'internal 'debug)
;; Don't provide globally.
