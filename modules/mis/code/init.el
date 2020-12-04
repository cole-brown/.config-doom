;;; mis/code/init.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Code & Comments
;;------------------------------------------------------------------------------

;; Always load `comment' unless specifically removed.
(unless (featurep! -comment)
   (load! "+comment"))
