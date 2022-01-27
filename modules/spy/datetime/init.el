;;; spy/datetime/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

;; Always load unless specifically removed.
(unless (featurep! -format)
  (imp:load :feature  '(:modules spy datetime +format)
            :filename "+format"))
(unless (featurep! -timestamp)
  (imp:load :feature  '(:modules spy datetime +timestamp)
            :filename "+timestamp"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'datetime)
