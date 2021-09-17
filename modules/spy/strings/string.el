;;; spy/strings/string.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Strings
;;------------------------------------------------------------------------------

(defun spy:string/concat (separator &rest inputs)
  "Concats INPUTS together with SEPARATOR in between.

INPUTS can be anything that `format' can deal with as a \"%s\" input type.
"
  (mapconcat (function (lambda (x) (format "%s" x)))
             inputs
             separator))


;;------------------------------------------------------------------------------
;; To String
;;------------------------------------------------------------------------------

(defun int<spy>:str:print->str (func &rest args)
  "Calls FUNC with ARGS, returns `standard-output' as a string."
  (with-output-to-string
    (apply func args)))


(defun int<spy>:str:insert->str (func &rest args)
  "Calls FUNC with ARGS in a temp buffer, then returns the temp buffer's
contents as a string."
  (with-temp-buffer
    (apply func args)
    (buffer-string)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'strings 'string)
