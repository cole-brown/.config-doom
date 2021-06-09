;;; spy/secret/config.el -*- lexical-binding: t; -*-
;;
;;; Code:


;;------------------------------------------------------------------------------
;; Requirements
;;------------------------------------------------------------------------------

;; Need load function.
(imp:require :modules 'spy 'secret)
(imp:require :jerky)


;;------------------------------------------------------------------------------
;; Load our specific system's config, if we have one.
;;------------------------------------------------------------------------------

(sss:secret/load 'emacs "config")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Already did `imp:provide' in init. Don't think we need to provide
;; anything here.
