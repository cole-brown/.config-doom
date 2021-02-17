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
;; Initialize the spy/jerky module.
;;
;;; Code:


;;------------------------------------------------------------------------------
;; Load The Rest
;;------------------------------------------------------------------------------

;; Always load `jerky' unless specifically removed.
(unless (featurep! -jerky)
  (load! "+jerky"))

;; Always load `dlv' unless specifically removed.
(unless (featurep! -dlv)
  (load! "+dlv"))
