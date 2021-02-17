;;; spy/lisp/init.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

;; Always load unless specifically removed.
(unless (featurep! -functions)
   (load! "+functions"))
(unless (featurep! -types)
   (load! "+types"))
