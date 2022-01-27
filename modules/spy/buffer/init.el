;;; spy/buffer/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load our sub-module thingies.
;;------------------------------------------------------------------------------

;; Always load unless specifically removed.
(imp:load :feature  '(:modules spy buffer delete)
          :filename "delete")
(imp:load :feature  '(:modules spy buffer eval)
          :filename "eval")
(imp:load :feature  '(:modules spy buffer line)
          :filename "line")
(imp:load :feature  '(:modules spy buffer manage)
          :filename "manage")
(imp:load :feature  '(:modules spy buffer name)
          :filename "name")
(imp:load :feature  '(:modules spy buffer point)
          :filename "point")
(imp:load :feature  '(:modules spy buffer search)
          :filename "search")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'buffer)
