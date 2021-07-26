;;; emacs/imp/error.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; String Helpers
;;------------------------------------------------------------------------------

(defun iii:error (func string &rest args)
  "Prepend FUNC string to STRING (the format-string for ARGS), then pass
formatted string and ARGS into `imp:error:function'.

Or, if `imp:error:function' is nil, just do nothing."
  (when imp:error:function
    (funcall imp:error:function
             "%s: %s" func (apply #'format string args))))
;; (iii:error "test:func" "True == %s" "False")
;; (let ((imp:error:function nil)) (iii:error "test:func" "True == %s" "False"))
;; (let ((imp:error:function #'message)) (iii:error "test:func" "True == %s" "False"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Don't provide - entirely internal to imp.
;; (imp:provide :imp 'error)
