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
          ((progn
             (condition-case err
                (int<imp>:load:feature feature:normal)
              ;; If loading by feature failed, then user needs to check their order of loading/requiring things. Let's give them some more info.
              (error
               (int<imp>:error:user "imp:require"
                                    '("Failed to find/load required feature: \n"
                                      "  input feature: %S\n"
                                      "  normalized:    %S\n"
                                 "Check your order of providing/loading, "
                                 "or make sure it initializes its root and "
                                 "features with imp first.\n"
                                 "Error: %S\n"
                                 "  %S")
                                    feature
                               feature:normal
                               (car err)
                               (cdr err))
              )
           ;; Yes; so add to imp's feature tree.
              (int<imp>:feature:add feature:normal)))
           )

          ;; Nope; return nil.
          (t
           nil))))
;; (imp:require 'test 'this)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :imp 'require)
