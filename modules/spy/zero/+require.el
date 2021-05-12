;; -*- mode: emacs-lisp; lexical-binding: t -*-


;;-------------------------------library of spy---------------------------------
;;--                           Provide/Require/...                            --
;;-----------------------------(books too maybe?)-------------------------------



;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Duplicate Functions
;;------------------------------------------------------------------------------

(defun sss:provide/normalize (input)
  "Normalize INPUT to a string. Removes all colons.
"
  (replace-regexp-in-string
   ":" ""
   (cond ((symbolp input)
          (symbol-name input))
         ((stringp input)
          input)
         (t
          (error "%s: Don't know how to normalize type of: %S"
                 "sss:provide/normalize" input)))))
;; (sss:provide/normalize 'jeff)
;; (sss:provide/normalize :jeff)
;; (sss:provide/normalize ":jeff")


;;------------------------------------------------------------------------------
;; Provide / Require
;;------------------------------------------------------------------------------

(defmacro spy:provide (module feature &rest extras)
  "Defines a feature using the power of /namespaces/!

MODULE should be a keyword. FEATURE and EXTRA can be keywords or
normal symbol-names.

Symbol values are ignored. The symbol names themselves are used
to construct the final feature symbol name. \":\" is discarded
from the front of keyword symbols.

Examples:

(spy:provide :spy path) will provide the feature with symbol-name:
'spy:path'

(spy:provide :spy mad-science transmogrifier) will provide the feature with
symbol-name: 'spy:mad-science/transmogrifier'
"
  (declare (indent defun))

  (when (not (keywordp module))
    (error "Module must be a keyword symbol. Got: %s" module))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mod-name     (make-symbol "temp-mod-name"))
        (feature-name (make-symbol "temp-feature-name"))
        (sub-names    (make-symbol "temp-sub-names")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mod-name ,module)
           (,feature-name ,feature)
           (,sub-names (list ,@extras))
           ;; Non-inputs:
           (final-name nil)
           (separator "/"))
       (setq final-name (concat (sss:provide/normalize ,mod-name)
                                separator
                                (sss:provide/normalize ,feature-name)))
       (when (not (null ,sub-names))
         (dolist (sub ,sub-names final-name)
           (setq final-name
                 (concat final-name
                         separator
                         (sss:provide/normalize sub)))))

       ;; Create/return the symbol in the obarray and provide the feature by
       ;; that name.
       (provide (intern final-name)))))
;; (featurep 'jeff/test/zero)
;; (spy:provide :jeff 'test 'zero)
;; (featurep 'jeff/test/zero)
;; jeff/test/zero
;; features
;; (featurep 'jeff/test/one)
;; (provide 'jeff/test/one)
;; (featurep 'jeff/test/one)
;; jeff/test/one
;; features


(defmacro spy:require (category module &rest extras)
  "Creates the module name from CATEGORY, MODULE, EXTRAS, then `requires' it.

CATEGORY should be a keyword. MODULE and EXTRA can be keywords or
normal symbol-names.

Symbol values are ignored. The symbol names themselves are used
to construct the final module symbol name. \":\" is discarded
from the front of keyword symbols.

The module is expected to be in the file described by the module name generated.

Examples:

(spy:require :spy path) will require the module:
  - symbol:  spy:path
  - path:   'spy:path'

(spy:require :spy mad-science transmogrifier) will require the module:
  - symbol:  spy:mad-science/transmogrifier
  - path:   'spy:mad-science/transmogrifier'
"
  (declare (indent defun))

  (when (not (keywordp category))
    (error "Category must be a keyword symbol. Got: %s" category))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((cat-name  (make-symbol "temp-cat-name"))
        (mod-name  (make-symbol "temp-mod-name"))
        (sub-names (make-symbol "temp-sub-names")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,cat-name ,category)
           (,mod-name ,module)
           (,sub-names (list ,@extras))
           ;; Non-inputs:
           (final-name nil)
           (separator "/"))
       (setq final-name (concat (sss:provide/normalize ,cat-name)
                                separator
                                (sss:provide/normalize ,mod-name)))
       (when (not (null ,sub-names))
         (dolist (sub ,sub-names final-name)
           (setq final-name
                 (concat final-name
                         separator
                         (sss:provide/normalize sub)))))

       ;; Create/return the symbol in the obarray and require the module by
       ;; that symbol in that filepath.
       (require (intern final-name) final-name))))
;; (featurep 'jeff/test/zero)
;; (spy:require :jeff 'test 'zero)
;; (featurep 'jeff/test/zero)
;; jeff/test/zero
;; features


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy:provide :spy 'zero 'require)
(spy:provide :spy 'zero 'provide)
