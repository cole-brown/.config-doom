;;; spy/collections/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

(imp:load :feature  '(:modules spy collections alist)
          :filename "alist")
(imp:load :feature  '(:modules spy collections hash-table)
          :filename "hash-table")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'collections)
