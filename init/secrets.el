;;; init/secrets.el -*- lexical-binding: t; -*-

;;--------------------------Initialize Our Secrets.-----------------------------
;;--               You're not allowed to know what they are.                  --
;;---------------------------------(shhh...)------------------------------------


;; Go get our Secrets if we have the system set up for it.
;; Only do this if we have:
;;   - A hash & id for this computer.
;;   - A valid root init.el for secrets.
;; secrets/init.el will do the per-computer stuff.
(sss:secret/init)
