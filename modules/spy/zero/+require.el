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

(defun spy//provide/symbol->str (symbol)
  "A copy of spy/zero/+strings.el's `spy/string/symbol->str', since we must
be loaded first.
"
  (replace-regexp-in-string ":" ""
                            (symbol-name symbol)))
;; (spy//provide/symbol->str 'jeff)
;; (spy//provide/symbol->str :jeff)


;;------------------------------------------------------------------------------
;; Provide / Require
;;------------------------------------------------------------------------------

(defmacro spy/provide (module feature &rest extras)
  "Defines a feature using the power of /namespaces/!

MODULE should be a keyword. FEATURE and EXTRA can be keywords or
normal symbol-names.

Symbol values are ignored. The symbol names themselves are used
to construct the final feature symbol name. \":\" is discarded
from the front of keyword symbols.

Examples:

(spy/provide :spy path) will provide the feature with symbol-name:
'spy/path'

(spy/provide :spy mad-science transmogrifier) will provide the feature with
symbol-name: 'spy/mad-science/transmogrifier'
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
       (setq final-name (concat (spy//provide/symbol->str ,mod-name)
                                separator
                                (spy//provide/symbol->str ,feature-name)))
       (when (not (null ,sub-names))
         (dolist (sub ,sub-names final-name)
           (setq final-name
                 (concat final-name
                         separator
                         (spy//provide/symbol->str sub)))))

       ;; Create/return the symbol in the obarray and provide the feature by
       ;; that name.
       (provide (intern final-name)))))
;; (featurep 'jeff/test/zero)
;; (spy/provide :jeff 'test 'zero)
;; (featurep 'jeff/test/zero)
;; jeff/test/zero
;; features


(defmacro spy/require (module feature &rest extras)
  "Creates the feature name from MODULE, FEATURE, EXTRAS, then `requires' it.

MODULE should be a keyword. FEATURE and EXTRA can be keywords or
normal symbol-names.

Symbol values are ignored. The symbol names themselves are used
to construct the final feature symbol name. \":\" is discarded
from the front of keyword symbols.

The feature is expected to be in the file described by the feature name generated.

Examples:

(spy/require :spy path) will require the feature:
  - symbol:  spy/path
  - path:   'spy/path'

(spy/require :spy mad-science transmogrifier) will require the feature:
  - symbol:  spy/mad-science/transmogrifier
  - path:   'spy/mad-science/transmogrifier'
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
       (setq final-name (concat (spy//provide/symbol->str ,mod-name)
                                separator
                                (spy//provide/symbol->str ,feature-name)))
       (when (not (null ,sub-names))
         (dolist (sub ,sub-names final-name)
           (setq final-name
                 (concat final-name
                         separator
                         (spy//provide/symbol->str sub)))))

       ;; Create/return the symbol in the obarray and require the feature by
       ;; that symbol in that filepath.
       (require (intern final-name) final-name))))
;; (featurep 'jeff/test/zero)
;; (spy/require :jeff 'test 'zero)
;; (featurep 'jeff/test/zero)
;; jeff/test/zero
;; features


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'zero 'require)
(spy/provide :spy 'zero 'provide)
