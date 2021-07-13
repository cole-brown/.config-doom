;;; init/init.el -*- lexical-binding: t; -*-

;; Anything required before config.el is run.
;; Shouldn't be much, if anything.


;;------------------------------------------------------------------------------
;; Includes
;;------------------------------------------------------------------------------

;;------------------------------
;; Set-Up imp Roots
;;------------------------------

(imp:path:root :modules (imp:path:paths->path doom-private-dir "modules"))
(imp:path:root :config (imp:path:paths->path doom-private-dir "config"))
(imp:path:root :init (imp:path:paths->path doom-private-dir "init"))


;;------------------------------
;; Include Some of my 'Packages'
;;------------------------------

;; Modules needed for .doom.d/config.el.
;; These /should/ all be loaded already via Doom's module init.
(imp:require :jerky)
(imp:require :modules 'spy 'file 'path)
(imp:require :modules 'spy 'system 'config)
(imp:require :modules 'spy 'system 'package)
(imp:require :modules 'spy 'secret)


;;------------------------------------------------------------------------------
;; Define Systems
;;------------------------------------------------------------------------------

(load! "systems")


;;------------------------------------------------------------------------------
;; Configure Secrets
;;------------------------------------------------------------------------------

(load! "secrets")
