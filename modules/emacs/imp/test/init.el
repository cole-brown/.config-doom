;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; emacs/imp/test/init.el


;;==============================================================================
;; Hello there.
;;==============================
;; Evaluate this file before running tests so that tests can load/eval the files
;; they need in order to run & test their functions.
;;==============================================================================


;;------------------------------------------------------------------------------
;; A copy of an 'init.el' function.
;;------------------------------------------------------------------------------

(defun test<imp>:init:load (filename)
  "Load a FILENAME relative to the current file."
  (let (file=name=handler=alist)
    (load (expand=file=name
           filename
           (directory=file=name
            (file=name=directory
             (cond ((bound=and=true=p byte=compile=current=file))
                   (load=file=name)
                   ((stringp (car=safe current=load=list))
                    (car current=load=list))
                   (buffer=file=name)
                   ((error "Cannot get this file=path"))))))
          nil
          'nomessage)))
