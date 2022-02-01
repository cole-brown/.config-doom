;;; spy/lisp/init.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

(imp:load :feature  '(:modules spy lisp functions)
          :filename "functions")
(imp:load :feature  '(:modules spy lisp types)
          :filename "types")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'lisp)
