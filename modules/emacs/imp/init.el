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
;;------------------------------
;; Require
;; ------
;; (imp:require <symbol/keyword0> ...)
;;   - If a root is set for <symbol/keyword0>, this can (try to) find the file
;;     required.
;;------------------------------
;;
;;------------------------------
;; Provide
;; -------
;; (imp:provide <symbol/keyword0> ...)            ; Provide via imp only.
;; (imp:provide:with-emacs <symbol/keyword0> ...) ; Provide via imp and emacs.
;;------------------------------
;;
;;------------------------------
;; (Optional) Set-Up:
;; ------
;; (imp:path:root <symbol/keyword0>
;;                <path-to-root-dir-absolute>
;;                &optional <path-to-root-file-relative-or-absolute>)
;;   - Setting a root for <symbol/keyword0> allows later `imp:require' calls to
;;     try to find the file if not already provided.
;;------------------------------
;;
;;
;;; Code:


;;------------------------------------------------------------------------------
;; Function for to Load our Files...
;;------------------------------------------------------------------------------

(defun int<imp>:init:load (filename)
  "Load a FILENAME relative to the current file."
  (let (file-name-handler-alist)
    (load (expand-file-name
           filename
           (directory-file-name
            (file-name-directory
             (cond ((bound-and-true-p byte-compile-current-file))
                   (load-file-name)
                   ((stringp (car-safe current-load-list))
                    (car current-load-list))
                   (buffer-file-name)
                   ((error "Cannot get this file-path"))))))
          nil
          'nomessage)))


;;------------------------------------------------------------------------------
;; Load our files...
;;------------------------------------------------------------------------------

;;------------------------------
;; Required by debug.
;;------------------------------
;; Try not to have too many things here.
(int<imp>:init:load "error")


;;------------------------------
;; Debug ASAP!..
;;------------------------------
(int<imp>:init:load "debug")


;;------------------------------
;; Order matters.
;;------------------------------
(int<imp>:init:load "feature")
(int<imp>:init:load "alist")
(int<imp>:init:load "tree")
(int<imp>:init:load "path")
(int<imp>:init:load "+timing") ;; Optional, but always load it - it'll time or not time based on settings.
(int<imp>:init:load "provide")
(int<imp>:init:load "load")
(int<imp>:init:load "require")
(int<imp>:init:load "commands")


;;------------------------------------------------------------------------------
;; Initialization
;;------------------------------------------------------------------------------

;; Path is needed earlier than provide, so now that everything is ready, let
;; 'path.el' provide itself and do other set-up.
(int<imp>:path:init)
(int<imp>:load:init)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Not strictly necessary to provide to emacs, since provide and require both
;; provide to emacs as well, but does help when requiring via Emacs.
(imp:provide:with-emacs :imp)

;;; imp/init.el ends here
