;;; spy/datetime/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

;; Always load unless specifically removed.
(unless (featurep! -format)
   (load! "+format"))
(unless (featurep! -timestamp)
   (load! "+timestamp"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'datetime)
