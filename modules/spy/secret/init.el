;;; spy/secret/init.el -*- lexical-binding: t; -*-
;;
;;; Code:


;; ┌───────────────────────────────────────────────────────────────────────────┐
;; │                        What's the Secret Word?                            │
;; └───────────────────────────────────────────────────────────────────────────┘


;;------------------------------------------------------------------------------
;; :spy:secret requirements
;;------------------------------------------------------------------------------

(imp:load :feature  '(:modules spy secret functions)
          :filename "functions")
(imp:load :feature  '(:modules spy secret load)
          :filename "load")


;;------------------------------------------------------------------------------
;; Notes
;;------------------------------------------------------------------------------
;;
;; User must call both:
;;   `spy:secret:init'
;;   `spy:secret:config'
;;
;; They should be called in .doom.d/config.el, before anything that may require
;; their secrets.
;;
;; `spy:secret:init' must be called very early on.
;;
;; `spy:secret:config' could be called just after `spy:secret:init', or later
;; on in config, depending on how you use your secrets' init/config.


;; Existance of secrets for this system is first checked for in `spy:secret:init'.


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'secret)
