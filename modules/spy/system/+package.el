;;; spy/system/+package.el -*- lexical-binding: t; -*-

(spy/require :spy 'zero 'strings)
(spy/require :spy 'path)
(spy/require :spy 'jerky)


;;------------------------------------------------------------------------------
;; Set Root.
;;------------------------------------------------------------------------------

(defconst -s//package.jerky.key "path/doom/package/root")


(defun spy/package.root/set (path)
  "Set the root path (can be relative) that `spy/package' will use.
"
  (jerky/set -s//package.jerky.key
             :value path
             :docstr "Root (can be relative) path for `spy/package'."))


;;------------------------------------------------------------------------------
;; Load Files During Config
;;------------------------------------------------------------------------------

(defmacro spy/package (&rest path)
  "Creates a relative filepath from PATH elements then looks under jerky key
\"path/doom/package/root\" for the (relative) root to that path.

PATH can be made up of strings or symbols.

For example:
  (jerky/set \"path/doom/package/root\" :value \"package\")
  (spy/package \"jeff\" \"jill\")

This will load file: \"package/jeff/jill.el(c)\"
"
  (declare (indent defun))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((path-input (make-symbol "temp-path")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let* ((,path-input (spy/string/symbol/normalize ,@path))
            ;; Non-inputs:
            (root        (jerky/get -s//package.jerky.key))
            (final-name  (apply #'spy/path/join root ,path-input))
            (package-name (apply #'spy/string/concat "/" ,path-input)))

       ;; Say something...
       (if (string= final-name package-name)
           ;; Say what we're loading.
           (message "spy/package loading '%s'..."
                    package-name)

         ;; Say what and where.
         (message "spy/package loading '%s'...\n   %s"
                  package-name final-name))

       ;; Use Doom's `load!' to load the file.
       (load! final-name))))
;; (spy/package 'jeff 'org-mode)
;; (spy/package 'identity)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'package)
