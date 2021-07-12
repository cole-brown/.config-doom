;; -*- mode: emacs-lisp; lexical-binding: t -*-


;;------------------Init & Config Help for Multiple Systems.--------------------
;;--                     What computer is this anyways?                       --
;;--------------------------(probably the wrong one)----------------------------



;;------------------------------------------------------------------------------
;; Namespaces
;;------------------------------------------------------------------------------

;; Always load `namespaces' unless specifically removed.
(unless (featurep! -namespaces)
  ;; Set-up Jerky namespaces for systems.
  (load! "+namespaces"))


;;------------------------------------------------------------------------------
;; Multiple systems (computers) able to use this same Doom Config.
;;------------------------------------------------------------------------------

;; Always load `multiplex' unless specifically removed.
(unless (featurep! -multiplex)
  (load! "+multiplex/init")
  ;; This init file will load the system definitions and whatever else is needed in the "+multiplex" dir.
  )


;;------------------------------------------------------------------------------
;; Loading Helpers.
;;------------------------------------------------------------------------------

;; Always load `init' unless specifically removed.
(unless (featurep! -init)
  (load! "+init"))

;; Always load `config' unless specifically removed.
(unless (featurep! -config)
  (load! "+config"))

;; Always load `package' unless specifically removed.
(unless (featurep! -package)
  (load! "+package"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'system)
