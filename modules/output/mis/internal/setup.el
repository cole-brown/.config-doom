;;; mis/internal/setup.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Set-Up: Nub
;;------------------------------------------------------------------------------

(defconst int<mis>:nub:user :nub
  "`nub' user for `mis'.")


(defconst int<mis>:debug:tags/common
  '() ;; None yet...
  "Common debug tags we should use for help in nub debug command prompts.")


(defun int<mis>:init ()
  "Initialize `mis' internals.

Initializes `nub' for usage in `mis'."
  (nub:vars:init int<mis>:nub:user
                 int<mis>:debug:tags/common
                 ;; Don't want to change any of the other defaults at the moment:
                 ;;   - prefix strings
                 ;;   - enabled flags
                 ;;   - sink functions
                 ))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :mis 'internal 'setup)
