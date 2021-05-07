;;; emacs/imp/error.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; String Helpers
;;------------------------------------------------------------------------------

(defun iii:error (func string &rest args)
  "Signal an error with STRING and ARGS passed into `error'.

STRING will have FUNC prepended."
  (error "%s: %s" func (apply #'format string args)))
;; (iii:error "test:func" "True == %s" "False")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Don't provide - entirely internal to imp.
;; (imp:provide :imp 'error)
