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
;; Tests: Unbind Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:layout:unbind
;;------------------------------

(ert-deftest test<keyboard>::int<keyboard>:layout:unbind ()
  "Test that `int<keyboard>:layout:unbind' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:layout:unbind"
      #'test<keyboard/layout>:setup
      #'test<keyboard/layout>:teardown


    ;;===
    ;; Run the test.
    ;;===
    (test<keyboard/layout>:assert:registrar-vars nil nil nil)

    ;;------------------------------
    ;; Valid Unbinds
    ;;------------------------------
    (let ((state :init)
          (unbinds '(:n "s" :layout:common:undefined)))

      (should (int<keyboard>:layout:unbind :debug   ;; registrar type (:debug, :actual)
                                           :testing ;; layout type
                                           :common  ;; keybind type (:emacs, :evil, :common)
                                           unbinds))

      ;; TODO: Fix `int<keyboard>:alist:update' bug first, then get back on this!

      ;; 1) Should have transitioned to init state.
      ;; 2) <no keybinds>
      ;; 3) Should now have the unbindings supplied above.
      (test<keyboard/layout>:assert:registrar-vars state nil unbinds))))
