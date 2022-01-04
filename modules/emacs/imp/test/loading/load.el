;; -*- no-byte-compile: t; -*-
;;; emacs/imp/test/loading/load.el


;;------------------------------------------------------------------------------
;; Loading Var/Func
;;------------------------------------------------------------------------------

(defvar test<imp/provide>:file:loading? nil
  "Gets set via `test<imp/provide>:load'.")


(defun test<imp/provide>:load:set ()
  "Check whether we're loading a file right now.

Sets `test<imp/provide>:file:loading?' with results from `imp:provide:loading?'."
  ;; Use setq so it gets set every time.
  (setq test<imp/provide>:file:loading?
        (imp:provide:loading?)))


(defun test<imp/provide>:load:unset ()
  "Remove `test<imp/provide>:file:loading?' from the symbol table.

That is: delete the variable from existance."
  (makunbound 'test<imp/provide>:file:loading?))
;; Probably exists to start off with:
;;   test<imp/provide>:file:loading?
;;   (test<imp/provide>:load:unset)
;; And now it should not exist:
;;   (should-error test<imp/provide>:file:loading?)


;;------------------------------
;; This exists in `provide.el' instead.
;;------------------------------
;; (defun test<imp/provide>:load:exists? ()
;;   "Returns t if `test<imp/provide>:file:loading?' exists in the symbol table."
;;   (condition-case err
;;       (progn
;;         ;; Just try to access this. If we can't, `condition-case' will catch the `void-variable' signal.
;;         test<imp/provide>:file:loading?
;;         ;; If we could access it, return `t' because it exists.
;;         t)
;;     ;; Couldn't access it, so it doesn't exist, so return nil.
;;     (void-variable nil)))
;; ;; Probably exists to start off with:
;; ;;   test<imp/provide>:file:loading?
;; ;;   (test<imp/provide>:load:exists?)
;; ;;   (test<imp/provide>:load:unset)
;; ;; And now it should not exist:
;; ;;   (test<imp/provide>:load:exists?)


;;------------------------------------------------------------------------------
;; Set on File Exec.
;;------------------------------------------------------------------------------
(test<imp/provide>:load:set)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
