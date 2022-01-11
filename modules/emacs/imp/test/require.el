;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; emacs/imp/test/require.el


;;------------------------------------------------------------------------------
;; Test Requirements
;;------------------------------------------------------------------------------

(load! "base.el")

(load! "../feature.el")
(load! "../alist.el")
(load! "../tree.el")
(load! "../path.el")
(load! "../+timing.el")
(load! "../provide.el")
(load! "../load.el")
(load! "../require.el")


;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

(defvar test<imp/require>:loading:root (imp:path:join (test<imp>:path/dir:this)
                                                      "loading")
  "The \"root\" directory for our 'imp/test/loading/load.el' file.")


(defvar test<imp/require>:loading:feature :loading
  "The feature name for our 'imp/test/loading/' files.")


(defvar test<imp/require>:loading:load:file "load"
  "The \"root\" filename (or filepath) for our 'imp/test/loading/load.el' file.")


(defvar test<imp/require>:loading:load:feature '(:loading load)
  "The feature name for our 'imp/test/loading/load.el' file.")


(defvar test<imp/require>:loading:dont-load:file "dont-load"
  "The \"root\" filename (or filepath) for our 'imp/test/loading/dont-load.el' file.")


(defvar test<imp/require>:loading:dont-load:feature '(:loading dont-load)
  "The feature name for our 'imp/test/loading/dont-load.el' file.")


(defvar test<imp/require>:loading:doesnt-exist:feature '(:loading doesnt-exist)
  "A feature name for 'imp/test/loading/doesnt-exist.el', which doesn't exist.")


;;------------------------------
;; Set-Up / Tear-Down
;;------------------------------

(defun test<imp/require>:setup:vars ()
  "Deletes variable from 'test/loading/*.el' files."
  ;; These are fine to do even if they already don't exist.
  (makunbound 'test<imp>:file:loading?)
  (makunbound 'test<imp>:loading:load:loaded)
  (makunbound 'test<imp>:loading:dont-load:loaded))


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠══════════╤══════════════════╧═══════════╧══════════════════╤══════════════╣
;; ╟──────────┤ Because Emacs needs to give Alists some love... ├──────────────╢
;; ╚══════════╧═════════════════════════════════════════════════╧══════════════╝


;;------------------------------------------------------------------------------
;; Tests: Imp Require Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; imp:require
;;------------------------------

(ert-deftest test<imp/require>::imp:require ()
  "Test that `imp:require' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/require>::imp:require"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    (test<imp/require>:setup:vars)
    (should-error test<imp>:file:loading?)
    (should-error test<imp>:loading:load:loaded)
    (should-error test<imp>:loading:dont-load:loaded)

    ;;------------------------------
    ;; Require feature & root.
    ;;------------------------------

    ;;---
    ;; Supply a root:
    ;;---
    ;; For testing that it can load something it knows about but that hasn't been required.
    (imp:path:root test<imp/require>:loading:feature
                   test<imp/require>:loading:root)

    ;;---
    ;; Require a feature:
    ;;---
    ;; For testing that nothing happens when it's already required.
    (apply #'imp:provide test<imp/require>:loading:dont-load:feature)

    ;;---
    ;; Set up variables:
    ;;---
    ;; First, set these variable to `nil' so they exist.
    (setq test<imp>:loading:load:loaded      nil  ;; If 'test/loading/load.el' is loaded, it will be set to `t'.
          test<imp>:loading:dont-load:loaded nil) ;; If 'test/loading/dont-load.el' is loaded, it will be set to `t'.

    ;;------------------------------
    ;; Load:
    ;;------------------------------

    ;;---
    ;; If feature is alredy required, nothing should happen.
    ;;---
    (should-not test<imp>:loading:dont-load:loaded)
    ;; Call `imp:require on it's feature; shouldn't be loaded since we've required it already.
    (should (apply #'imp:require
                   test<imp/require>:loading:dont-load:feature))
    (should-not test<imp>:loading:dont-load:loaded)

    ;;---
    ;; If we know the base feature, we should be able to load the file by the feature name.
    ;;---
    (should-not test<imp>:loading:load:loaded)
    (should (apply #'imp:require
                   test<imp/require>:loading:load:feature))
    (should test<imp>:loading:load:loaded)
    (should test<imp>:file:loading?)
    ;; And it should now be provided.
    (should (apply #'imp:provided? test<imp/require>:loading:load:feature))

    ;;------------------------------
    ;; Errors:
    ;;------------------------------

    ;;---
    ;; Know the base feature, but can't find anything to load.
    ;;---
    (should-error test<imp>:loading:load:doesnt-exist)
    (should-error (apply #'imp:require
                         test<imp/require>:loading:doesnt-exist:feature))
    (should-error test<imp>:loading:load:doesnt-exist)

    ;;---
    ;; Don't know the base feature.
    ;;---
    ;; We fallback to asking Emacs to `require' it, but it doesn't know anything about this either.
    ;; This won't error; it'll just return nil.
    (should-not (imp:require 'something-that-doesnt-exist-in-emacs))))
