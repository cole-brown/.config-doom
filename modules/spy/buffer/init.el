;;; spy/buffer/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

;; Always load unless specifically removed.
(unless (featurep! -delete)
   (load! "+delete"))
(unless (featurep! -point)
   (load! "+eval"))
(unless (featurep! -line)
   (load! "+line"))
(unless (featurep! -manage)
   (load! "+manage"))
(unless (featurep! -name)
   (load! "+name"))
(unless (featurep! -point)
   (load! "+point"))
(unless (featurep! -search)
   (load! "+search"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'buffer)
