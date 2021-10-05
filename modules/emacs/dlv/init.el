;;; emacs/dlv/init.el -*- lexical-binding: t; -*-

;;;;; init.el --- Init for spy/jerky doom module. -*- lexical-binding: t; -*-
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

(load! "path")
(load! "class") ;; requires path

(load! "dlv") ;; requires path, class,

;; Always load unless specifically removed.
(unless (featurep! -display)
  (load! "+display"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :dlv)
