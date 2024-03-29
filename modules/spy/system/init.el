;; -*- mode: emacs-lisp; lexical-binding: t -*-


;;------------------Init & Config Help for Multiple Systems.--------------------
;;--                     What computer is this anyways?                       --
;;--------------------------(probably the wrong one)----------------------------



;;------------------------------------------------------------------------------
;; Namespaces
;;------------------------------------------------------------------------------

;; Set-up Jerky namespaces for systems.
(imp:load :feature  '(:modules spy system namespaces)
          :filename "namespaces")


;;------------------------------------------------------------------------------
;; Multiple systems (computers) able to use this same Doom Config.
;;------------------------------------------------------------------------------

(imp:load :feature  '(:modules spy system multiplex)
          :filename "multiplex")


;;------------------------------------------------------------------------------
;; Loading Helpers.
;;------------------------------------------------------------------------------

(imp:load :feature  '(:modules spy system dlv)
          :filename "dlv")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'system)
