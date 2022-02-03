;;; init/init.el -*- lexical-binding: t; -*-

;; Anything required before config.el is run.
;; Shouldn't be much, if anything.


;;------------------------------------------------------------------------------
;; Includes
;;------------------------------------------------------------------------------

;; Enable imp timing.
(customize-set-variable 'imp:timing:enabled? t)


;;------------------------------
;; Set-Up imp Roots
;;------------------------------

(imp:path:root :modules (imp:path:join doom-private-dir "modules"))
(imp:path:root :config  (imp:path:join doom-private-dir "config"))
(imp:path:root :init    (imp:path:join doom-private-dir "init"))


;;------------------------------
;; Include Some of my 'Packages'
;;------------------------------

;; Modules needed for .doom.d/config.el.
;; These /should/ all be loaded already via Doom's module init.
(imp:require :path)
(imp:require :jerky)
(imp:require :modules 'spy 'secret)


;;------------------------------------------------------------------------------
;; Define Systems
;;------------------------------------------------------------------------------

(imp:load :feature  '(:dot-emacs init systems)
          :path     (imp:path:current:dir/relative :dot-emacs)
          :filename "systems")


;;------------------------------------------------------------------------------
;; Configure Secrets
;;------------------------------------------------------------------------------

(imp:load :feature  '(:dot-emacs init secrets)
          :path     (imp:path:current:dir/relative :dot-emacs)
          :filename "secrets")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'init)
