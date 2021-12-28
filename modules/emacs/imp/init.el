;;; imp/init.el --- Structured IMPort/export of elisp features  -*- lexical-binding: t; -*-

;; Author: Cole Brown <code@brown.dev>
;; Created: 2021-05-07
;; Keywords: languages, lisp
;; Version: 1.0.20211228
;; URL: https://github.com/cole-brown/.config-doom
;; Package-Requires: ((emacs "27.1"))

;;; Commentary:
;;------------------------------------------------------------------------------
;; Usage
;;------------------------------------------------------------------------------
;;
;;------------------
;; Require
;; ------
;; (imp:require <symbol/keyword0> ...)
;;   - If a root is set for <symbol/keyword0>, this can (try to) find the file
;;     required.
;;------------------
;;
;;------------------
;; Provide
;; -------
;; (imp:provide <symbol/keyword0> ...)            ; Provide via imp only.
;; (imp:provide:with-emacs <symbol/keyword0> ...) ; Provide via imp and emacs.
;;------------------
;;
;;------------------
;; (Optional) Set-Up:
;; ------
;; (imp:path:root <symbol/keyword0>
;;                <path-to-root-dir-absolute>
;;                &optional <path-to-root-file-relative-or-absolute>)
;;   - Setting a root for <symbol/keyword0> allows later `imp:require' calls to
;;     try to find the file if not already provided.
;;------------------
;;
;;
;;; Code:



;;------------------------------------------------------------------------------
;; Load our files...
;;------------------------------------------------------------------------------

;;------------------
;; Required by debug.
;;------------------
;; Try not to have too many things here.
(load! "error")


;;------------------
;; Debug ASAP!..
;;------------------
(load! "debug")


;;------------------
;; Order matters.
;;------------------
(load! "feature")
(load! "alist")
(load! "tree")
(load! "path")
(load! "provide")
(load! "require")
(load! "commands")

;; Path was needed earlier than provide, so now we need to let path
;; provide itself.
(iii:path:provide)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Not strictly necessary to provide to emacs, since provide and require both
;; provide to emacs as well, but does help when requiring via Emacs.
(imp:provide:with-emacs :imp)

;;; imp/init.el ends here
