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


(defun imp:require (feature:base &rest feature)
  "Ensures file(s) for FEATURE:BASE keyword & FEATURE symbols are provided.

Examples:
  (imp:root :mis \"path/to/mis\")

  To require/load \"mis/code/comment.el[c]\":
    (imp:require :mis 'code 'comment)

  To require/load \"mis/code/*.el[c]\":
    (imp:require :mis 'code)

Returns non-nil on success."
  ;; TODO:load: the load-all functionality
  ;; Already provided?
  (cond ((apply #'imp:provided? feature:base feature)
         t)

        ;; Can we load it?
        ((apply #'int<imp>:load feature:base feature)
         ;; Yes; so add to imp's feature tree.
         (int<imp>:feature:add (cons feature:base feature)))

        ;; Nope; return nil.
        (t
         nil)))
;; (imp:require 'test 'this)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :imp 'require)
