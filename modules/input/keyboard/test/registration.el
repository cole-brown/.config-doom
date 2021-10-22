;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/registration.el

;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(load! "base.el")

;;---
;; Keyboard Files:
;;---
(load! "../vars.el")
(load! "../load.el")
(load! "../alist.el")
(load! "../registrars.el")
(load! "../registration.el")


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Registrars Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:registration:valid/action?
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:registration:valid/action? ()
  "Test that `int<keyboard>:registration:valid/action?' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:registration:valid/action?"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Valid Inputs
    ;;------------------------------
    (should (int<keyboard>:registration:valid/action? :bind))
    (should (int<keyboard>:registration:valid/action? :unbind))
    (should (int<keyboard>:registration:valid/action? :full))

    ;;------------------------------
    ;; Invalid Inputs
    ;;------------------------------
    (should-not (int<keyboard>:registration:valid/action? :invalid))
    (should-not (int<keyboard>:registration:valid/action? 'invalid))
    (should-not (int<keyboard>:registration:valid/action? 42))))


;; TODO:
;; TODO: rename all the registration.el functions
;; TODO:
