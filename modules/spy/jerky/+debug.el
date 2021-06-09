;;; spy/jerky/+debug.el -*- lexical-binding: t; -*-

;;; Commentary:

;; Debugging functionality for jerky.

;;------------------------------------------------------------------------------
;; Debugging Toggle
;;------------------------------------------------------------------------------

(defvar jerky//debugging nil
  "Debug flag.")


(defun jerky//debug/toggle ()
  "Toggle debugging for jerky."
  (interactive)
  (setq jerky//debugging (not jerky//debugging))
  (message "jerky//debugging: %s"
           (if jerky//debugging
               "enabled"
             "disabled")))


;;------------------------------------------------------------------------------
;; Debugging Functions
;;------------------------------------------------------------------------------

(defun jerky//debug (func msg &rest args)
  "Print out a debug message if debugging."
  (when jerky//debugging
    (apply #'message
           (concat func ": " msg)
           args)))
;; (jerky//debug "test")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :jerky 'debug)
