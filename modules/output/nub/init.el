;;;; init.el --- Init for :output/nub doom module. -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Cole Brown
;;
;; Author: Cole Brown <http://github/cole-brown>
;; Maintainer: Cole Brown <code@brown.dev>
;; Created: 2021-11-30
;; Modified: 2021-11-30
;; Version: 0.0.1
;; Keywords: lisp
;; Homepage: https://github.com/cole-brown/.config-doom
;; Package-Requires: ((emacs 27.1))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Initialize the ':output/nub' module.
;;
;;; Code:

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║               Nub: /noun/ A small lump or protuberance.                ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                       Hey... Naming things is hard.                        ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Set imp Root
;;------------------------------------------------------------------------------

(imp:path:root :path
               (imp:path:paths->path doom-private-dir
                                     "modules"
                                     "output"
                                     "nub")
               "init.el")


;;------------------------------------------------------------------------------
;; Load Files
;;------------------------------------------------------------------------------

(load! "internal")
(load! "alist")
(load! "utils")
(load! "variables")
(load! "output")
(load! "debug")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub)
