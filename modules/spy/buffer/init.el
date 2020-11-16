;;; spy/buffer/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

;; Always load unless specifically removed.
(unless (featurep! -point)
   (load! "+point"))
(unless (featurep! -line)
   (load! "+line"))
