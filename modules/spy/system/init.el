;; -*- mode: emacs-lisp; lexical-binding: t -*-


;;------------------Init & Config Help for Multiple Systems.--------------------
;;--                     What computer is this anyways?                       --
;;--------------------------(probably the wrong one)----------------------------

(imp:require :jerky)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;; Default fallback is ok.
(jerky/namespace/create :work ;; Work Namespace
           :title "Namespace for the Job"
           :docstr "Work/Job-related variables.")

;; Default fallback is ok.
(jerky/namespace/create :home ;; Home Namespace
           :title "Namespace for House & Home"
           :docstr "Homework, Side-Projects, Personal Notes, etc...")

;; Default fallback is ok.
(jerky/namespace/create :secret ;; Secret Namespace
           :title "Namespace for the Confidential"
           :docstr "You've seen this, so... Now I have to kill you, I guess?"
           :fallbacks :jerky/namespace/no-fallback)

;; Default system namespace - can overwrite during system multiplex init.
(jerky/set "namespace/system"
           :default ;; System Namespace
           :title "Namespace for the Confidential"
           :docstr "You've seen this, so... Now I have to kill you, I guess?"
           :fallbacks :jerky/namespace/no-fallback)


;;------------------------------------------------------------------------------
;; Multiple systems (computers) able to use this same Doom Config.
;;------------------------------------------------------------------------------

;; Always load `multiplex' unless specifically removed.
(unless (featurep! -multiplex)
   (load! "+multiplex"))


;;------------------------------------------------------------------------------
;; Config/Load Helpers.
;;------------------------------------------------------------------------------

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
