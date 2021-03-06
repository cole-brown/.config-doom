;;; emacs/imp/require.el -*- lexical-binding: t; -*-


;; imp requirements:
;;   - :imp 'debug
;;   - :imp 'error
;;   - :imp 'path
;;   - :imp 'provide


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Private Functions
;;------------------------------------------------------------------------------

;; TODO: a load timing feature?
;;   - One in `iii:load' that will:
;;     1. start timer, output: "loading xxx..."?
;;     2. stop timer, output:  "└─yy.zzz seconds"
;;     3. Look nice when cascading?
;;        "loading xxx..."
;;        "├─loading yyy..."
;;        "│ └─cc.dd seconds"
;;        "└─aa.bb seconds"
;;     4. Output to some buffer named by defcustom (default "*Messages*").
;;  - One or two stand-alone, external-api-named funcs (that `iii:load' calls?).
;;  - An easy way to defadvice-wrap Emacs' `load' in the timing thing.


(defun iii:load (root &rest feature)
  "Load a file relative to ROOT based on FEATURE list of keywords/symbols.

ROOT must be a keyword which exists in `imp:path:roots' (set via the
`imp:path:root'function).

E.g. (iii:load :imp 'provide)
  Will try to load: \"/path/to/imp-root/provide.el\"

Returns non-nil if loaded."
  ;; TODO: 'load-all' functionality?

  (cond ((apply #'imp:provided? root feature)
         t)

        ;; Not loaded, but we know where to find it?
        ((iii:path:root/contains? root)
         ;; imp knows about this - let's try to load it.
         (let* ((path (iii:path:get (cons root feature))))
           (condition-case-unless-debug err
               (let (file-name-handler-alist)
                 (load path nil 'nomessage))

             (iii:error "iii:load"
                        "imp fail to load %S via path: %S\n  - error: %S"
                        (cons root features)
                        path
                        err))))

        ;; Fallback: Try to let emacs require it:
        (t
         (require (iii:feature:imp->emacs feature)
                 ;; TODO: guess at a file/path based on 'root/feature-0/...'?
                 nil
                 'noerror))))
;; (iii:load :imp 'something)
;; (iii:load :config 'spy 'system 'config)


;;------------------------------------------------------------------------------
;; Public API: Require
;;------------------------------------------------------------------------------


(defun imp:require (root &rest names)
  "Loads file(s) indicated by NAMES from ROOT keyword if not already loaded.

Examples:
  (imp:root :mis \"path/to/mis\")

  To require/load \"mis/code/comment.el[c]\":
    (imp:load :mis 'code 'comment)

  To require/load \"mis/code/*.el[c]\":
    (imp:load :mis 'code)

Returns non-nil on success."
  ;; TODO: the load-all functionality
  ;; Already provided?
  (cond ((apply #'imp:provided? root names)
         t)

        ;; Can we load it?
        ((apply #'iii:load root names)
         ;; Yes; so add to imp's feature tree.
         (iii:feature:add (cons root feature)))

        ;; Nope; return nil.
        (t
         nil)))
;; (imp:require 'test 'this)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :imp 'require)
