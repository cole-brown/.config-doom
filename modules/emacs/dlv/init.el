;;; init.el --- Init for DLV doom module. -*- lexical-binding: t; -*-
;;

;; Copyright (C) 2020-2021  Cole Brown
;; Author: Cole Brown <http://github/cole-brown>
;; Maintainer: Cole Brown <code@brown.dev>
;; Created: 2020-07-14
;; Modified: 2021-02-14
;; Version: 3.0
;; Keywords:
;; Homepage: https://github.com/cole-brown/.config-doom
;;
;;; Commentary:
;;
;; Code-Defined Directory Local Variables
;; Code-Defined File Local Variables
;;
;; ------------------------------
;; NOTE: Namespaces
;; ---
;; dlv has three 'namespace' prefixes:
;;   `dlv:'       - public/API functions, variables, etc
;;   `int<dlv>:'  - private/internal functions, variables, etc
;;   `test<dlv>:' - Emacs ERT functions, variables, etc
;; ------------------------------
;;
;; TODO: describe flags
;; Flags:
;;   - +debug
;;   - -enabled
;;   - +enabled/safe
;;   - +enabled/all
;;   - +enabled/flag
;;   - -display
;;
;;; Code:


;;------------------------------------------------------------------------------
;; Set imp Root
;;------------------------------------------------------------------------------

(imp:path:root :dlv
               (imp:path:paths->path doom-private-dir
                                     "modules"
                                     "emacs"
                                     "dlv")
               "init.el")


;;------------------------------------------------------------------------------
;; Load Files.
;;------------------------------------------------------------------------------

;;------------------------------
;; Debugging
;;------------------------------

(load! "debug")

;;------------------------------
;; Actual Functions
;;------------------------------

(load! "path")
(load! "class") ;; requires path

(load! "dlv") ;; requires path, class,

;;------------------------------
;; Optional Files
;;------------------------------

;; Always load unless specifically removed.
(unless (featurep! -display)
  (load! "+display"))


;;------------------------------------------------------------------------------
;; Optional Functionality
;;------------------------------------------------------------------------------

;; Only run the optional functionality checks/enables when loading.
(when (imp:provide:loading?)
  ;;------------------------------
  ;; Enable debugging now (if feature flagged for it).
  ;;------------------------------
  (int<dlv>:debug:init-if-flagged)

  ;;------------------------------
  ;; Enable/disable DLVs?
  ;;------------------------------
  ;; If we're loading, check for a feature flag for how to enable DLVs.
  (cond ((featurep! -enabled) ;; Not enabled == disabled.
         (dlv:enable :disable))
        ((featurep! +enabled/safe) ;; Only safe DLVs allowed!
         (dlv:enable :safe))
        ((featurep! +enabled/all) ;; Always allow anything - potentially dangerous!
         (dlv:enable :all))
        ((featurep! 'dlv :emacs +enabled/prompt) ;; Always ask the user.
         (dlv:enable :prompt))
        ;; Default: Always enable DLVs unless specifically told not to.
        (t
         (dlv:enable :enable))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :dlv)
