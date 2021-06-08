;;; spy/buffer/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

;; Always load unless specifically removed.
(unless (featurep! -point)
   (load! "+point"))
(unless (featurep! -line)
   (load! "+line"))
(unless (featurep! -search)
   (load! "+search"))
(unless (featurep! -name)
   (load! "+name"))
(unless (featurep! -delete)
   (load! "+delete"))
(unless (featurep! -manage)
   (load! "+manage"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'buffer)
