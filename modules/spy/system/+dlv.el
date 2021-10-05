;;; spy/system/+dlv.el -*- lexical-binding: t; -*-

(imp:require :dlv)
(imp:require 'taskspace)
(imp:require :jerky '+dlv)


;;------------------------------------------------------------------------------
;; Set common Dir Local Variables for systems.
;;------------------------------------------------------------------------------

(defun spy:system/domain:dlv (dir-path domain-keyword)
  "Sets Dir Local Variables for a domain in DIR-PATH.

Sets `taskspace' and `jerky' DLVs for DIR-PATH/global-mode to DOMAIN-KEYWORD.

See `dlv:set' for setting other Dir Local Variables."
  (taskspace/group/dlv domain-keyword dir-path)
  (jerky/dlv/namespace.set dir-path domain-keyword))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'system 'dlv)
