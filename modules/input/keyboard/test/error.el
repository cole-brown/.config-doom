;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/test.el

;;------------------------------------------------------------------------------
;; Test Keyboard Layouts
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(load "base.el")

;;---
;; Keyboard Files:
;;---
(load "../error.el")


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Functions
;;------------------------------------------------------------------------------

;; TODO: from here
;;------------------------------
;; int<keyboard>:error:normalize/key
;;------------------------------

(ert-deftest test<keyboard/error>::int<keyboard>:error:normalize/key ()
  "Test that `int<keyboard>:error:normalize/key' behaves."

  (test<keyboard>:fixture
      ;; Test name, teardown func.
      "test<keyboard/error>:simple/stupid"
      nil
      nil

    ;; Run the test.

    ;;---
    ;; Good values:
    ;;---

    (should (string= "foo"
                     (int<keyboard>:error:normalize/key "foo")))
    (should (string= "<RET>"
                     (int<keyboard>:error:normalize/key '[RET])))

    ;;---
    ;; Bad values get converted to string and warning message.
    ;;---
    ;;
    ;; TODO
    (should t)))


;;------------------------------
;; int<keyboard>:error:format
;;------------------------------

(ert-deftest test<keyboard/error>::int<keyboard>:error:format ()
  "Test that `int<keyboard>:error:format' behaves."

  (test<keyboard>:fixture
      ;; Test name, teardown func.
      "test<keyboard/error>:simple/stupid"
      nil

    ;; Run the test.
    ;; TODO
    (should t)))


;;------------------------------
;; int<keyboard>:error:message
;;------------------------------

(ert-deftest test<keyboard/error>::int<keyboard>:error:message ()
  "Test that `int<keyboard>:error:message' behaves."

  (test<keyboard>:fixture
      ;; Test name, teardown func.
      "test<keyboard/error>:simple/stupid"
      nil

    ;; Run the test.
    ;; TODO
    (should t)))
