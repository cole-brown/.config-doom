;; -*- mode: emacs-lisp; lexical-binding: t -*-


;;------------------Init & Config Help for Multiple Systems.--------------------
;;--                     What computer is this anyways?                       --
;;--------------------------(probably the wrong one)----------------------------

(spy/require :spy 'jerky)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(jerky/set :default ;; System Namespace
           'name
           :value "The Default Namespace"
           :docstr "Fallback domain if a var isn't in its expected domain.")

(jerky/set :work ;; System Namespace
           'name
           :value "Namespace for the Job"
           :docstr "Work/Job-related variables.")

(jerky/set :home ;; System Namespace
           'name
           :value "Namespace for House & Home"
           :docstr "Homework, Side-Projects, Personal Notes, etc...")

(jerky/set :secret ;; System Namespace
           'name
           :value "Namespace for the Confidential"
           :docstr "You've seen this, so... Now I have to kill you, I guess?")

;; TODO [2020-10-16]: jerky/namespace instead of jerky/set, and make jerky/namespace.
;; and make jerky/set, jerky/get use primary/fallback namespaces.

;; §-TODO-§ [2020-10-23]: Set :default as the jerky fallback if not found in
;; first path. Think it's adding functionality to jerky. Think dirky has it.


;;------------------------------------------------------------------------------
;; System UID
;;------------------------------------------------------------------------------

;; Always load `multiplex' unless specifically removed.
(unless (featurep! -multiplex)
   (load! "+multiplex"))
