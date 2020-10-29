;;;;; init.el --- Init for spy/jerky doom module. -*- lexical-binding: t; -*-
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
;; Initialize the spy/jerky module.
;;
;;; Code:


;;------------------------------------------------------------------------------
;; Load The Rest
;;------------------------------------------------------------------------------

;; Always load `jerky' unless specifically removed.
(unless (featurep! -jerky)
  (load! "+jerky"))
