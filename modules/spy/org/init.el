;; -*- mode: emacs-lisp; lexical-binding: t -*-


;;------------------------------------------------------------------------------
;; Org-Mode Stuff
;;------------------------------------------------------------------------------

;; Always load unless specifically removed.
(unless (featurep! -keyword)
   (load! "+keyword"))
(unless (featurep! -link)
   (load! "+link"))
