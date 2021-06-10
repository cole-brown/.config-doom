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
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'strings 'string)
