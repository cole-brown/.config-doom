;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; output/nub/test/utils.el

;;------------------------------------------------------------------------------
;; Test Requirements
;;------------------------------------------------------------------------------

(load! "base.el")


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════╤═══════════╧═══════════╧════════════╤════════════════════╣
;; ╟─────────────────┤ Test the utility of the utilities. ├────────────────────╢
;; ╚═════════════════╧════════════════════════════════════╧════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<nub>:normalize->string
;;------------------------------

(ert-deftest test<nub/utils>::int<nub>:normalize->string ()
  "Test that `int<nub>:normalize->string' behaves."

  (test<nub>:fixture
      ;; Test name, nub user, setup func, teardown func.
      "test<nub/utils>::int<nub>:normalize->string"
      :user/auto
      nil
      nil


    ;;---
    ;; Bad values should error on `symbol-name'?
    ;;---
    ;; Not a string or a symbol -> ERROR
    (should-error (int<nub>:normalize->string '(invalid)))

    ;;---
    ;; Good values:
    ;;---
    (should (string= "test"
                     (int<nub>:normalize->string "+test")))
    (should (string= "test"
                     (int<nub>:normalize->string "layout/test")))
    (should (string= "test"
                     (int<nub>:normalize->string "layout/+test")))
    (should (string= "test"
                     (int<nub>:normalize->string :test)))
    (should (string= "test"
                     (int<nub>:normalize->string :layout/test)))
    (should (string= "test"
                     (int<nub>:normalize->string :layout/+test)))
    (should (string= "test"
                     (int<nub>:normalize->string 'test)))
    (should (string= "test"
                     (int<nub>:normalize->string 'layout/test)))
    (should (string= "test"
                     (int<nub>:normalize->string 'layout/+test)))))


;;------------------------------
;; int<nub>:normalize->keyword
;;------------------------------

(ert-deftest test<nub/utils>::int<nub>:normalize->keyword ()
  "Test that `int<nub>:normalize->keyword' behaves."

  (test<nub>:fixture
      ;; Test name, nub user, setup func, teardown func.
      "test<nub/utils>::int<nub>:normalize->keyword"
      :user/auto
      nil
      nil

    ;;---
    ;; Bad values should error on `symbol-name'?
    ;;---
    ;; Not a string or a symbol -> ERROR
    (should-error (int<nub>:normalize->keyword '(invalid)))

    ;;---
    ;; Good values:
    ;;---
    (should (eq :test
                (int<nub>:normalize->keyword "+test")))
    (should (eq :test
                (int<nub>:normalize->keyword "layout/test")))
    (should (eq :test
                (int<nub>:normalize->keyword "layout/+test")))
    (should (eq :test
                (int<nub>:normalize->keyword :test)))
    (should (eq :test
                (int<nub>:normalize->keyword :layout/test)))
    (should (eq :test
                (int<nub>:normalize->keyword :layout/+test)))
    (should (eq :test
                (int<nub>:normalize->keyword 'test)))
    (should (eq :test
                (int<nub>:normalize->keyword 'layout/test)))
    (should (eq :test
                (int<nub>:normalize->keyword 'layout/+test)))))
