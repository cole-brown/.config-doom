;;; spy/lisp/init.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

;; Always load unless specifically removed.
(unless (featurep! -functions)
  (imp:load :feature  '(:modules spy lisp +functions)
            :filename "+functions"))
(unless (featurep! -types)
  (imp:load :feature  '(:modules spy lisp +types)
            :filename "+types"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'lisp)
