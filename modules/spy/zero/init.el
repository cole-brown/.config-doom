;;; init.el --- Init for :spy/files doom module. -*- lexical-binding: t; -*-
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
;; Initialize the :spy/files module.
;;
;;; Code:


;;------------------------------------------------------------------------------
;; Set up a Thing...
;;------------------------------------------------------------------------------

(defgroup spy:group nil
  "General group namespace for the defcustoms in my emacs init."
  :prefix "spy:"
  ;; not really sure where to stick it
  :group 'convenience)


;;------------------------------------------------------------------------------
;; ...Load The Rest
;;------------------------------------------------------------------------------

;; ;; Always load `strings' unless specifically removed.
;; (unless (featurep! -strings)
;;   (load! "+strings"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'zero)
