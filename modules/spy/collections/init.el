;;; spy/collections/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

;; Always load unless specifically removed.
(unless (featurep! -alist)
   (load! "+alist"))
(unless (featurep! -hash-table)
   (load! "+hash-table"))
