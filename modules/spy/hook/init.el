;;; spy/hook/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Hook Helpers
;;------------------------------------------------------------------------------

;; Always load `def' unless specifically removed.
(unless (featurep! -def)
   (load! "+def"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'hook)
