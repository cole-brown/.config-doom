;;; emacs/str/init.el --- Init for string helpers doom module. -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021  Cole Brown
;; Author: Cole Brown <http://github/cole-brown>
;; Maintainer: Cole Brown <code@brown.dev>
;; Created: 2021-09-10
;; Modified: 2021-09-10
;; Version: 0.1
;; Keywords:
;; Homepage: https://github.com/cole-brown/.config-doom
;; Package-Requires: ((emacs "27.1"))
;;
;;; Commentary:
;;
;; Helpful string functions.
;;
;;; Code:


;;------------------------------------------------------------------------------
;; Set up imp.
;;------------------------------------------------------------------------------
(imp:path:root :str
               (imp:path:paths->path doom-private-dir
                                     "modules"
                                     "emacs"
                                     "str")
               "init.el")

;;------------------------------------------------------------------------------
;; Load files.
;;------------------------------------------------------------------------------

(unless (featurep! -case)
  (load! "+case"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :str)
