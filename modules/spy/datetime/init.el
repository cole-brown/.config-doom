;;; spy/datetime/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

(imp:load :feature  '(:modules spy datetime format)
          :filename "format")
(imp:load :feature  '(:modules spy datetime timestamp)
          :filename "timestamp")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'datetime)
