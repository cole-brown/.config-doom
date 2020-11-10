;;; spy/system/+load.el -*- mode: emacs-lisp; lexical-binding: t; -*-

(spy/require :spy 'zero 'strings)
(spy/require :spy 'path)
(spy/require :spy 'jerky)


;;------------------------------------------------------------------------------
;; Set Root.
;;------------------------------------------------------------------------------

(defconst spy//config.jerky.key "path/doom/config/root")


(defun spy/config.root/set (path)
  "Set the root path (can be relative) that `spy/config' will use.
"
  (jerky/set spy//config.jerky.key
             :value path
             :docstr "Root (can be relative) path for `spy/config'."))


;;------------------------------------------------------------------------------
;; Load Files During Config
;;------------------------------------------------------------------------------

(defmacro spy/config (&rest path)
  "Creates a relative filepath from PATH elements then looks under jerky key
\"path/doom/config/root\" for the (relative0 root to that path.

PATH can be made up of: strings, symbols, and functions that take no
arguments and return a string.

For example:
  (jerky/set \"path/doom/config/root\" :value \"config\")
  (spy/config \"jeff\" \"jill\")

This will load file: \"config/jeff/jill.el(c)\"
"
  (declare (indent defun))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((path-input (make-symbol "temp-path")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let* ((,path-input (spy/string/symbol/normalize ,@path))
            ;; Non-inputs:
            (root        (jerky/get "path/doom/config/root"))
            (final-name  (apply #'spy/path/join root ,path-input))
            (config-name (apply #'spy/string/concat "/" ,path-input)))

       ;; Say something...
       (if (string= final-name config-name)
           ;; Say what we're loading.
           (message "spy/config loading '%s'..."
                    config-name)

         ;; Say what and where.
         (message "spy/config loading '%s'...\n   %s"
                  config-name final-name))

       ;; Use Doom's `load!' to load the file.
       (load! final-name))))
;; (spy/config 'jeff 'org-mode)
;; (spy/config 'identity)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'config)
