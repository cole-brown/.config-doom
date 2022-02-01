;;; spy/system/+namespaces.el -*- lexical-binding: t; -*-

;;---------------------Jerky Namespaces for the System(s)-----------------------
;;--                           Default Namespaces                             --
;;------------------------------------------------------------------------------


(imp:require :jerky)

;;------------------------------------------------------------------------------
;; Namespaces
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
(jerky/set 'namespace 'system
           :default ;; System Namespace
           :title "Default namespace for the System/Computer"
           :docstr "Default Namespace - no fallback."
           :fallbacks :jerky/namespace/no-fallback)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'system 'namespaces)
