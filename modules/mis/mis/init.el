;;; mis/init/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Load local files...
;;------------------------------------------------------------------------------

;; Always load load. Cannot load anything else without it.
(load! "+load")

;; Load debug if not undesired...
(unless (featurep! -debug)
  (load! "../internal/+debug"))


;;------------------------------------------------------------------------------
;; Load more of mis now that we can load...
;;------------------------------------------------------------------------------

;;------------------
;; Internal Functions
;;------------------
(-m//require 'internal 'const)
(-m//require 'internal 'valid)
(-m//require 'internal 'mlist)
(-m//require 'internal 'mout)

;;------------------
;; Args / Sections
;;------------------
(-m//require 'args 'string)
(-m//require 'args 'style)

;;------------------
;; Code-Related Things
;;------------------
(-m//require 'code 'comment)

;;------------------
;; Messages
;;------------------
(-m//require 'mis 'message)


(provide 'mis)
