;;; emacs/imp/require.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Require Features                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                     Require Imp feature symbol paths.                      ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Private Functions
;;------------------------------------------------------------------------------

;; TODO: a load timing feature?
;;   - One in `int<imp>:load' that will:
;;     1. start timer, output: "loading xxx..."?
;;     2. stop timer, output:  "└─yy.zzz seconds"
;;     3. Look nice when cascading?
;;        "loading xxx..."
;;        "├─loading yyy..."
;;        "│ └─cc.dd seconds"
;;        "└─aa.bb seconds"
;;     4. Output to some buffer named by defcustom (default "*Messages*").
;;  - One or two stand-alone, external-api-named funcs (that `int<imp>:load' calls?).
;;  - An easy way to defadvice-wrap Emacs' `load' in the timing thing.
;; TODO: Think that would be an optional file '+output.el'?
;; TODO: Or like debug - triggers off of a module flag or a toggle var?
;;       - Also should trigger off of Emacs' "--debug-init" command line arg.


(defun int<imp>:load (feature:base &rest feature)
  "Load a file relative to FEATURE:BASE based on FEATURE list of keywords/symbols.

FEATURE:BASE must be a keyword which exists in `imp:path:roots' (set via the
`imp:path:root'function).

E.g. (int<imp>:load :imp 'provide)
  Will try to load: \"/path/to/imp-root/provide.el\"

Returns non-nil if loaded."
  ;; TODO: 'load-all' functionality?

  (cond ((apply #'imp:provided? feature:base feature)
         t)

        ;; Not loaded, but we know where to find it?
        ((int<imp>:path:root/contains? feature:base)
         ;; imp knows about this - let's try to load it.
         (let* ((path (int<imp>:path:get (cons feature:base feature))))
           (condition-case-unless-debug err
               (let (file-name-handler-alist)
                 (load path nil 'nomessage))

             (int<imp>:error "int<imp>:load"
                        "imp fail to load %S via path: %S\n  - error: %S"
                        (cons feature:base features)
                        path
                        err))))

        ;; Fallback: Try to let emacs require it:
        (t
         (require (int<imp>:feature:normalize:imp->emacs feature)
                 ;; TODO: guess at a file/path based on 'feature:base/feature-0/...'?
                 nil
                 'noerror))))
;; (int<imp>:load :imp 'something)
;; (int<imp>:load :config 'spy 'system 'config)


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
  ;; TODO: the load-all functionality
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
