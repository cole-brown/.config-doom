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


;;------------------------------------------------------------------------------
;; Define Systems
;;------------------------------------------------------------------------------

(load! "systems.el")


;;------------------------------------------------------------------------------
;; Configure Secrets
;;------------------------------------------------------------------------------

