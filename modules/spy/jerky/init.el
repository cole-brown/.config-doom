;;; init.el --- Init for spy/jerky doom module. -*- lexical-binding: t; -*-
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
;; Set imp Root
;;------------------------------------------------------------------------------

(imp:path:root :jerky
               (imp:path:join doom-private-dir
                              "modules"
                              "spy"
                              "jerky")
               "init.el")


;;------------------------------------------------------------------------------
;; Load Jerky Files.
;;------------------------------------------------------------------------------

(imp:load :feature  '(:jerky debug)
          :filename "debug")
(imp:load :feature  '(:jerky jerky)
          :filename "jerky")

;; Always load `dlv' unless specifically removed.
(unless (featurep! -dlv)
  (imp:load :feature  '(:jerky +dlv)
            :filename "+dlv"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :jerky)
