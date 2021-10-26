;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/layout/base.el


;;------------------------------------------------------------------------------
;; Load all files tested by tests one folder up.
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(load! "../base.el")

;;---
;; Keyboard Files:
;;---
(load! "../../output.el")
(load! "../../debug.el")
(load! "../../utils.el")
(load! "../../alist.el")
(load! "../../vars.el")
(load! "../../load.el")
(load! "../../alist.el")
(load! "../../registrars.el")
