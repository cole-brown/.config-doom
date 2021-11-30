;;;; init.el --- Init for :spy/path doom module. -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Cole Brown
;;
;; Author: Cole Brown <http://github/cole-brown>
;; Maintainer: Cole Brown <code@brown.dev>
;; Created: October 22, 2020
;; Modified: October 22, 2020
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/cole-brown/.config-doom
;; Package-Requires: ((emacs 27.1) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Initialize the spy/path module.
;;
;;; Code:


;;------------------------------------------------------------------------------
;; Load The Rest
;;------------------------------------------------------------------------------

;; Always load.
(load! "path")
(load! "files")



;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'path)
