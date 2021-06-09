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
;; Configure Secrets
;;------------------------------------------------------------------------------

;; Go get our Secrets if we have the system set up for it.
;; Only do this if we have:
;;   - A hash & id for this computer.
;;   - A valid root init.el for secrets.
;; secrets/init.el will do the per-computer stuff.
(sss:secret/load 'emacs "init")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'secret)
