;;; spy/system/+package.el -*- lexical-binding: t; -*-

(imp:require :modules 'spy 'strings)
(imp:require :modules 'spy 'file 'path)
(imp:require :jerky)


;;------------------------------------------------------------------------------
;; Set Root.
;;------------------------------------------------------------------------------

(defconst sss:package.jerky.key "path/doom/package/root")


(defun spy:package.root/set (path)
  "Set the root path (can be relative) that `spy:package' will use.
"
  (jerky/set sss:package.jerky.key
             :value path
             :docstr "Root (can be relative) path for `spy:package'."))


;;------------------------------------------------------------------------------
;; Load Files During Config
;;------------------------------------------------------------------------------

(defmacro spy:package (&rest path)
  "Creates a relative filepath from PATH elements then looks under jerky key
\"path/doom/package/root\" for the (relative) root to that path.

PATH can be made up of strings or symbols.

For example:
  (jerky/set \"path/doom/package/root\" :value \"package\")
  (spy:package \"jeff\" \"jill\")

This will load file: \"package/jeff/jill.el(c)\"
"
  (declare (indent defun))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((path-input (make-symbol "temp-path")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let* ((,path-input (str:normalize:name->list ,@path))
            ;; Non-inputs:
            (root        (jerky/get sss:package.jerky.key))
            (final-name  (apply #'spy:path:join root ,path-input))
            (package-name (apply #'str:join "/"
                                 (apply #'str:normalize:value->list ,path-input))))

       ;; Say something...
       (if (string= final-name package-name)
           ;; Say what we're loading.
           (message "spy:package loading '%s'..."
                    package-name)

         ;; Say what and where.
         (message "spy:package loading '%s'...\n   %s"
                  package-name final-name))

       ;; Use Doom's `load!' to load the file.
       (load! final-name))))
;; (spy:package 'jeff 'org-mode)
;; (spy:package 'identity)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'system 'package)
