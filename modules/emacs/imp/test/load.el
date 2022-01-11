;; -*- no-byte-compile: t; lexical-binding: t; -*-
;; -*- no-byte-compile: t; -*-
;;; emacs/imp/test/load.el


;;------------------------------------------------------------------------------
;; Test Requirements
;;------------------------------------------------------------------------------

(load! "base.el")

(load! "../feature.el")
(load! "../alist.el")
(load! "../tree.el")
(load! "../path.el")
(load! "../+timing.el")
(load! "../load.el")


;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

(defvar test<imp/load>:loading:root (imp:path:join (test<imp>:path/dir:this)
                                                      "loading")
  "The \"root\" directory for our 'imp/test/loading/load.el' file.")


(defvar test<imp/load>:loading:feature :loading
  "The feature name for our 'imp/test/loading/' files.")


(defvar test<imp/load>:loading:load:file "load"
  "The \"root\" filename (or filepath) for our 'imp/test/loading/load.el' file.")


(defvar test<imp/load>:loading:load:feature '(:loading load)
  "The feature name for our 'imp/test/loading/load.el' file.")


(defvar test<imp/load>:loading:dont-load:file "dont-load"
  "The \"root\" filename (or filepath) for our 'imp/test/loading/dont-load.el' file.")


(defvar test<imp/load>:loading:dont-load:feature '(:loading dont-load)
  "The feature name for our 'imp/test/loading/dont-load.el' file.")


(defvar test<imp/load>:loading:doesnt-exist:feature '(:loading doesnt-exist)
  "A feature name for 'imp/test/loading/doesnt-exist.el', which doesn't exist.")


;;------------------------------
;; Set-Up / Tear-Down
;;------------------------------

(defun test<imp/load>:setup:vars ()
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
;; Tests: Imp Load Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<imp>:load:file
;;------------------------------
;; Is just a wrapper around `load'; testing other `:imp/load' functions will test
;; this fine (until we encounter a bug in this function, I guess).


;;------------------------------
;; int<imp>:load
;;------------------------------

(ert-deftest test<imp/load>::int<imp>:load ()
  "Test that `int<imp>:load' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/load>::int<imp>:load"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    (test<imp/load>:setup:vars)
    (should-error test<imp>:file:loading?)
    (should-error test<imp>:loading:load:loaded)
    (should-error test<imp>:loading:dont-load:loaded)

    ;;------------------------------
    ;; Load feature & root.
    ;;------------------------------

    ;;---
    ;; Supply a root:
    ;;---
    ;; For testing that it can load something it knows about but that hasn't been loaded yet.
    (imp:path:root test<imp/load>:loading:feature
                   test<imp/load>:loading:root)

    ;;---
    ;; Load a feature:
    ;;---
    ;; For testing that nothing happens when it's already loaded.
    (apply #'imp:provide test<imp/load>:loading:dont-load:feature)

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
    ;; If feature is alredy loaded, nothing should happen.
    ;;---
    (should-not test<imp>:loading:dont-load:loaded)
    ;; Call `int<imp>:load on it's feature; shouldn't be loaded since we've loaded it already.
    (should (apply #'int<imp>:load
                   test<imp/load>:loading:dont-load:feature))
    (should-not test<imp>:loading:dont-load:loaded)

    ;;---
    ;; If we know the base feature, we should be able to load the file by the feature name.
    ;;---
    (should-not test<imp>:loading:load:loaded)
    (should (apply #'int<imp>:load
                   test<imp/load>:loading:load:feature))
    (should test<imp>:loading:load:loaded)
    (should test<imp>:file:loading?)

    ;;------------------------------
    ;; Errors:
    ;;------------------------------

    ;;---
    ;; Know the base feature, but can't find anything to load.
    ;;---
    (should-error test<imp>:loading:load:doesnt-exist)
    (should-error (apply #'int<imp>:load
                         test<imp/load>:loading:doesnt-exist:feature))
    (should-error test<imp>:loading:load:doesnt-exist)

    ;;---
    ;; Don't know the base feature.
    ;;---
    ;; We fallback to asking Emacs to `load' it, but it doesn't know anything about this either.
    ;; This won't error; it'll just return nil.
    (should-not (int<imp>:load 'something-that-doesnt-exist-in-emacs))))
