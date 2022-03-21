;;; init.el --- Init for taskspace doom module. -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020-2021  Cole Brown
;; Author: Cole Brown <http://github/cole-brown>
;; Maintainer: Cole Brown <code@brown.dev>
;; Created: 2019-04-24
;; Modified: 2021-02-14
;; Version: 2.1
;; Keywords:
;; Homepage: https://github.com/cole-brown/.config-doom
;; Package-Requires: ((emacs "27.1"))
;;
;;; Commentary:
;;
;; Initialize the taskspace module.
;;
;;; Code:


;;------------------------------------------------------------------------------
;; Set up imp.
;;------------------------------------------------------------------------------
(imp:path:root :taskspace
               (imp:path:join doom-private-dir
                              "modules"
                              "taskspace"
                              "taskspace")
               "init.el")

;;------------------------------------------------------------------------------
;; Load it!
;;------------------------------------------------------------------------------

(imp:load :feature  '(:taskspace taskspace)
          :filename "taskspace")

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :taskspace)
