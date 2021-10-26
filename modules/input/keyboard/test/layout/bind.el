;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/layout/bind.el

;;------------------------------------------------------------------------------
;; Test Layout
;;------------------------------------------------------------------------------

;;---
;; Test Files:
;;---
;; "test/layout/base.el" will load "test/base.el" and all tested files from "test/__.el" level.
(load! "base.el")

;;---
;; Keyboard Layout Files:
;;---
(load! "../../layout/bind.el")


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Bind Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:layout:bind
;;------------------------------

;; TODO:
;; TODO: Start writing this test!
;; TODO:
(ert-deftest test<keyboard/alist>::int<keyboard>:layout:bind ()
  "Test that `int<keyboard>:layout:bind' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:layout:bind"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Valid Inputs
    ;;------------------------------
    (should (int<keyboard>:layout:bind :bind))
    (should (int<keyboard>:layout:bind :unbind))
    (should (int<keyboard>:layout:bind :full))

    ;;------------------------------
    ;; Invalid Inputs
    ;;------------------------------
    (should-not (int<keyboard>:layout:bind :invalid))
    (should-not (int<keyboard>:layout:bind 'invalid))
    (should-not (int<keyboard>:layout:bind 42))))
