;;; init.el --- Init for :output/nub doom module. -*- lexical-binding: t; -*-
;; Copyright (C) 2020 Cole Brown
;;
;; Author: Cole Brown <http://github/cole-brown>
;; Maintainer: Cole Brown <code@brown.dev>
;; Created: 2021-11-30
;; Modified: 2021-11-30
;; Version: 0.0.1
;; Keywords: lisp
;; Homepage: https://github.com/cole-brown/.config-doom
;; Package-Requires: ((emacs "27.1"))
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

(imp:path:root :nub
               (imp:path:join doom-private-dir
                              "modules"
                              "output"
                              "nub")
               "init.el")


;;------------------------------------------------------------------------------
;; Load Files
;;------------------------------------------------------------------------------

(imp:load :feature  '(:nub internal)
          :filename "internal")
(imp:load :feature  '(:nub alist)
          :filename "alist")
(imp:load :feature  '(:nub utils)
          :filename "utils")
(imp:load :feature  '(:nub variables)
          :filename "variables")
(imp:load :feature  '(:nub output)
          :filename "output")
(imp:load :feature  '(:nub debug)
          :filename "debug")
(imp:load :feature  '(:nub debug format)
          :filename "debug-format")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub)
