;;; mis/internal/+debug.el -*- lexical-binding: t; -*-

;;; Commentary:

;; Debugging functionality for mis.


(imp:require :mis 'setup)


;;------------------------------------------------------------------------------
;; Debugging Toggle
;;------------------------------------------------------------------------------

(defun mis//debugging (&optional tags)
  "Returns non-nil when `nub' output level `:debug' is enabled for TAGS.

If TAGS is nil, returns non-nil when `nub' global debugging is enabled."
  (nub:debug:active? int<mis>:nub:user
                     tags))


(defun mis//debug/toggle ()
  "Toggle debugging flag for `mis'; leave debugging tags alone."
  (interactive)
  (nub:debug:toggle int<mis>:nub:user))


(defun mis//debug/tag (tag)
  "Toggle a debugging keyword tag."
  (interactive)
  (nub:debug:tag int<mis>:nub:user
                 tag))


;;------------------------------------------------------------------------------
;; Debugging Functions
;;------------------------------------------------------------------------------
;; Just use `nub:debug', `nub:debug:func/start', `nub:debug:func/end', etc...


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Don't provide globally.
(imp:provide :mis 'debug)
