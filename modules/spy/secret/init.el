;;; spy/secret/init.el -*- lexical-binding: t; -*-
;;
;;; Code:


;; todo: spy-fan

(imp:require :jerky)
(imp:require :modules 'spy 'file 'path)

(require 'mis0/message)


;;------------------------------------------------------------------------------
;; :spy:secret requirements
;;------------------------------------------------------------------------------

(load! "load")


;;------------------------------------------------------------------------------
;; Notes
;;------------------------------------------------------------------------------
;;
;; User must call both:
;;   `spy:secret/init'
;;   `spy:secret/config'
;;
;; They should be called in .doom.d/config.el, before anything that may require
;; their secrets.
;;
;; `spy:secret/init' must be called very early on.
;;
;; `spy:secret/config' could be called just after `spy:secret/init', or later
;; on in config, depending on how you use your secrets' init/config.


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'secret)
