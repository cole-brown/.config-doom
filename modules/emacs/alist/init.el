;;; init.el --- Init for :emacs/alist doom module. -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Cole Brown
;;
;; Author:           Cole Brown <http://github/cole-brown>
;; Maintainer:       Cole Brown <code@brown.dev>
;; Created:          2021-12-15
;; Modified:         2021-12-15
;; Version:          0.0.1
;; Keywords:         lisp
;; Homepage:         https://github.com/cole-brown/.config-doom
;; Package-Requires: ((emacs "27.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Initialize the ':emacs/alist' module.
;;
;;; Code:

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                           Association Lists                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;   - Namespaced so you can find related functions.                          ;;
;;   - Other useful things, probably.                                         ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Set imp Root
;;------------------------------------------------------------------------------

(imp:path:root :alist
               (imp:path:join doom-private-dir
                              "modules"
                              "emacs"
                              "alist")
               "init.el")


;;------------------------------------------------------------------------------
;; Load Files
;;------------------------------------------------------------------------------

(load! "internal")

;;---
;; General/Generic Alist Functionality
;;---
(load! "type/types") ;; 'generic.el' needs these functions/vars.
(load! "generic")

;;---
;; Typed Alists
;;---
(load! "type/default")
(load! "type/keyword")
(load! "type/string")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :alist)
