;;; spy/secret/init.el -*- lexical-binding: t; -*-
;;
;;; Code:


;; todo: spy-fan

(spy/require :spy 'jerky)
(spy/require :spy 'path)

(require 'mis0/message)


;;------------------------------------------------------------------------------
;; :spy/secret requirements
;;------------------------------------------------------------------------------

(load! "load")


;;------------------------------------------------------------------------------
;; Configure Secrets
;;------------------------------------------------------------------------------

;; Go get our Secrets if we have the system set up for it.
;; Only do this if we have:
;;   - A hash & id for this computer.
;;   - A valid root init.el for secrets.
;; secrets/init.el will do the per-computer stuff.
(spy//secret/load 'emacs "init")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'secret)
