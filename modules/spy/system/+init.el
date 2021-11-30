;;; spy/system/+init.el -*- lexical-binding: t; -*-

(imp:require :modules 'spy 'strings 'normalize)
(imp:require :modules 'spy 'file 'path)
(imp:require :jerky)


;;------------------------------------------------------------------------------
;; Set Root.
;;------------------------------------------------------------------------------

(defconst sss:init.jerky.key "path/doom/init/root")


(defun spy:init.root/set (path)
  "Set the root path (can be relative) that `spy:init' will use.
"
  (jerky/set sss:init.jerky.key
             :value path
             :docstr "Root (can be relative) path for `spy:init'."))
;; (spy:init.root/set "init")


;;------------------------------------------------------------------------------
;; Load Files During Init
;;------------------------------------------------------------------------------

(defmacro spy:init (&rest path)
  "Creates a relative filepath from PATH elements then looks under jerky key
\"path/doom/init/root\" for the (relative) root to that path.

PATH can be made up of strings or symbols.

For example:
  (jerky/set \"path/doom/init/root\" :value \"init\")
  (spy:init \"jeff\" \"jill\")

This will load file: \"init/jeff/jill.el(c)\"
"
  (declare (indent defun))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((path-input (make-symbol "temp-path")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let* ((,path-input (str:normalize:name->list ,@path))
            ;; Non-inputs:
            (root       (jerky/get sss:init.jerky.key))
            (final-name (apply #'spy:path:join root ,path-input))
            (init-name  (apply #'str:join "/"
                                (apply #'str:normalize:value->list ,path-input))))

       ;; Say something...
       (if (string= final-name init-name)
           ;; Say what we're loading.
           (message "spy:init loading '%s'..."
                    init-name)

         ;; Say what and where.
         (message "spy:init loading '%s'...\n   %s"
                  init-name final-name))

       ;; Use Doom's `load!' to load the file.
       (load! final-name))))
;; (spy:init 'jeff 'org-mode)
;; (spy:init 'identity)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'system 'init)
