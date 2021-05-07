;;; emacs/imp/+debug-off.el -*- lexical-binding: t; -*-

;;; Commentary:

;; Mock debugging functionality for imp.

;;------------------------------------------------------------------------------
;; Debugging Toggle
;;------------------------------------------------------------------------------

(defconst iii:debugging nil
  "Debug currently disable - useless var.")


(defun imp:debug:toggle ()
  "No-op. Debug currently disabled."
  nil)


;;------------------------------------------------------------------------------
;; Debugging Functions
;;------------------------------------------------------------------------------

(defun iii:debug (func msg &rest args)
  "No-op. Debug currently disabled."
  (ignore func msg args))
;; (iii:debug "test_func" "test")


(defun iii:debug:newline ()
  "Prints a newline if debugging."
  nil)
;; (iii:debug:newline)

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Don't provide. Imp internal only.
