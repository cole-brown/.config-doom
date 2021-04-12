;;; mis0/internal/+debug.el -*- lexical-binding: t; -*-

;;; Commentary:

;; Debugging functionality for mis0.

;;------------------------------------------------------------------------------
;; Debugging Toggle
;;------------------------------------------------------------------------------

(defvar mis0//debugging nil
  "Debug flag.")


(defun mis0//debug/toggle ()
  "Toggle debugging for mis0."
  (interactive)
  (setq mis0//debugging (not mis0//debugging))
  (message "mis0//debugging: %s"
           (if mis0//debugging
               "enabled"
             "disabled")))


;;------------------------------------------------------------------------------
;; Debugging Functions
;;------------------------------------------------------------------------------

(defun mis0//debug (func msg &rest args)
  "Print out a debug message if debugging."
  (when mis0//debugging
    (apply #'message
           (concat func ": " msg)
           args)))
;; (mis0//debug "test_func" "test")


(defmacro mis0//when-debugging (&rest body)
  "Only run BODY when debug flag is set."
  (declare (indent defun))
  `(when mis0//debugging
     ,@body))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'internal 'debug)
;; Don't provide globally.
