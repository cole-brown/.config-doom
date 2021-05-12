;;; spy/zero/+hook.el -*- lexical-binding: t; -*-

(require 'dash)
(spy:require :spy 'path)


;;------------------------------------------------------------------------------
;; Helpers for Hookers...
;;------------------------------------------------------------------------------
;; ...um...

;; from here:
;; https://www.reddit.com/r/emacs/comments/1m7fqv/avoid_lambda_in_hooks_use_defun_instead/cc83axz/
(defmacro spy:hook/defun-and-hooker (hook-var options &rest body)
  "Macro that `defun's a function called 'sss:hook/<hook-name>'
and adds the hook function to HOOK-VAR.

OPTIONS is a plist of optional vars:
  :name     - Hook function will be named 'sss:hook/<name>'.
              If no `:name', name will be set to `(symbol-name HOOK-VAR)'.

  :quiet    - Do not output 'Running hook' message.

  :postpend - Passed on to `add-hook'. If non-nil, hook will be postpended to
              the list of hooks. If nil, hook will be prepended.

  :file     - Filename where your macro is called from... in case you happen
              to lose your hook.

  :docstr   - A string to use as the defined function's docstring.

BODY is the code to run in the hook.
"
  (declare (indent 1))
  ;; Eval inputs once.
  (-let* ((_m//hook hook-var)
          ;; dash-let's plist match pattern to non-keys in ARGS.
          ((&plist :name _m//name
                   :quiet _m//quiet
                   :postpend _m//postpend
                   :file _m//file
                   :docstr _m//docstr)
           (eval options))
          (_m//hook-name (concat "sss:hook/"
                                  (if _m//name
                                      _m//name
                                    ;; Remove "-hook"?
                                    (s-chop-suffix "-hook" (symbol-name _m//hook)))))
          (_m//hook-fn (intern _m//hook-name)))

    `(progn
       (defun ,_m//hook-fn () ,_m//docstr
              (unless ,_m//quiet
                ;; Nice info message maybe?
                (message
                 "Running hook `%s'%s..."
                 ,_m//hook-name
                 (if (not (stringp ,_m//file))
                     ""
                   (concat " from "
                           (spy:path/to-relative ,_m//file)))))

              ,@body)
       (add-hook ',_m//hook #',_m//hook-fn ',_m//postpend))))
;; (setq test-hook nil)
;; (makunbound sss:hook/test)
;; (spy:hook/defun-and-hooker test-hook nil (message "Hello there."))
;; (spy:hook/defun-and-hooker test-hook nil (message "Hello there."))
;; test-hook
;; (run-hooks 'test-hook)
;; (setq debug-on-error t)
;; (setq test-hook nil)
;; (spy:hook/defun-and-hooker test-hook '(:name "jeff/mcjefferson" :file "here") (message "Hello there."))
;; test-hook
;; (run-hooks 'test-hook)


(defmacro spy:hook/defun (hook-var options &rest body)
  "Macro that `defun's a function called 'sss:hook/<hook-name>'.

OPTIONS is a plist of optional vars:
  :name     - Hook function should be named 'sss:hook/<name>'.
              If no `:name', name will be set to `(symbol-name HOOK-VAR)'
              minus any '-hook' suffix.

  :quiet    - Do not output 'Running hook' message.

  :file     - Filename where your macro is called from... in case you happen
              to lose your hook.

  :docstr   - A string to use as the defined function's docstring.

BODY is the code to run in the hook.

Use this over `spy:hook/defun-and-hooker' only in cases where you aren't
`add-hook'ing directly (e.g. for use-package's ':hook').
"
  (declare (indent 1))
  ;; Eval inputs once.
  (-let* ((_m//hook hook-var)
          ;; dash-let's plist match pattern to non-keys in ARGS.
          ((&plist :name _m//name
                   :quiet _m//quiet
                   :postpend _m//postpend
                   :file _m//file
                   :docstr _m//docstr)
           (eval options))
          (_m//hook-name (concat "sss:hook/"
                                 (if _m//name
                                     _m//name
                                   ;; Remove "-hook"?
                                   (s-chop-suffix "-hook" (symbol-name _m//hook)))))
          (_m//hook-fn (intern _m//hook-name)))

    `(defun ,_m//hook-fn () ,_m//docstr
            (unless ,_m//quiet
              ;; Nice info message maybe?
              (message
               "Running hook `%s'%s..."
               ,_m//hook-name
               (if (not (stringp ,_m//file))
                   ""
                 (concat " from "
                         (spy:path/to-relative ,_m//file)))))

            ,@body)
    ))
;; (setq test-hook nil)
;; (spy:hook/defun test-hook nil (message "Hello there."))
;; (add-hook 'test-hook 'sss:hook/test)
;; test-hook
;; (run-hooks 'test-hook)
;; (setq test-hook nil)
;; (spy:hook/defun test-hook '(:name "captain-hook" :file "here") (message "hi."))
;; (add-hook 'test-hook 'sss:hook/captain)
;; test-hook
;; (run-hooks 'test-hook)



;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy:provide :spy 'hook 'def)
