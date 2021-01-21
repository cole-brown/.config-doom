;;; mis/init/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load local files...
;;------------------------------------------------------------------------------

;; Always load load. Cannot load anything else without it.
(load! "+load")


;;------------------------------------------------------------------------------
;; Load more of mis now that we can load...
;;------------------------------------------------------------------------------

;;------------------
;; Internal Functions
;;------------------
(-m//require 'internal 'mlist)

;;------------------
;; Args / Sections
;;------------------
(-m//require 'args 'string)
(-m//require 'args 'style)

;;------------------
;; Code-Related Things
;;------------------
(-m//require 'code 'comment)


(provide 'mis)
