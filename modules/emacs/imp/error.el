;;; emacs/imp/error.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Error Function
;;------------------------------------------------------------------------------

(defcustom imp:error:function
  #'error
  "A function to call for imp errors.

If you desire to not raise error signals during init, for instance, change this
to:
  - #'warn    - Produce a warning message
  - #'message - just send error to *Messages* buffer.
  - nil       - Silently ignore errors (not recommended).
  - Your own function with parameters: (format-string &rest args)"
  :type '(choice (const #'error)
                 (const #'warn)
                 (const #'message)
                 (const nil :tag "nil - Silently ignore errors.")
                  function)
  :group 'imp:group)


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
