;;; emacs/imp/require.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Require Features                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                     Require Imp feature symbol paths.                      ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Public API: Require
;;------------------------------------------------------------------------------


(defun imp:require (&rest feature)
  "Ensures file(s) for FEATURE:BASE keyword & FEATURE symbols are provided.

Examples:
  (imp:root :mis \"path/to/mis\")

  To require/load \"mis/code/comment.el[c]\":
    (imp:require :mis 'code 'comment)

  To require/load \"mis/code/*.el[c]\":
    (imp:require :mis 'code)

Returns non-nil on success."
  (let ((feature:normal (int<imp>:feature:normalize feature)))
    ;; Already provided?
    (cond ((imp:provided? feature:normal)
           t)

          ;; Can we load it?
          ((int<imp>:load:feature feature:normal)
           ;; Yes; so add to imp's feature tree.
           (int<imp>:feature:add feature:normal))

          ;; Nope; return nil.
          (t
           nil))))
;; (imp:require 'test 'this)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :imp 'require)
