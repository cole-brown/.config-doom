;;; emacs/dlv/debug.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Debugging Help
;;------------------------------------------------------------------------------

(defvar int<dlv>:debug/enabled? nil
  "Debug flag.")


(defun int<dlv>:debug:toggle ()
  "Toggle debugging for DLV."
  (interactive)
  (setq int<dlv>:debug/enabled? (not int<dlv>:debug/enabled?))
  (message "DLV debugging: %s"
           (if int<dlv>:debug/enabled?
               "enabled"
             "disabled")))


(defun int<dlv>:debug (func msg &rest args)
  "Print out a debug message if debugging."
  (when int<dlv>:debug/enabled?
    (apply #'message
           (concat func ": " msg)
           args)))
;; (int<dlv>:debug "test")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :dlv 'debug)
