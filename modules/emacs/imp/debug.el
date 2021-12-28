;;; emacs/imp/+debug.el -*- lexical-binding: t; -*-

;;; Commentary:

;; Debugging functionality for imp.

;;------------------------------------------------------------------------------
;; Debugging Toggle
;;------------------------------------------------------------------------------

(defvar iii:debugging nil
  "Debug flag.")


(defun imp:debug:toggle ()
  "Toggle debugging for imp."
  (interactive)
  (setq iii:debugging (not iii:debugging))
  (message "imp:debugging: %s"
           (if iii:debugging
               "enabled"
             "disabled")))


;;------------------------------------------------------------------------------
;; Debugging Functions
;;------------------------------------------------------------------------------

(defun iii:debug (func msg &rest args)
  "Print out a debug message if debugging."
  (when iii:debugging
    (apply #'message
           (concat func ": " msg)
           args)))
;; (iii:debug "test_func" "test")


(defun iii:debug:newline ()
  "Prints a newline if debugging."
  (when iii:debugging
    (message " ")))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
