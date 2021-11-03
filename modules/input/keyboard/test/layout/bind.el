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
      ;; Clear out keybinds before test.
      #'test<keyboard/layout>:setup
      #'test<keyboard/layout>:teardown


    ;;===
    ;; Run the test.
    ;;===
    ;; They should all be nil right now.
    (test<keyboard/layout>:assert:registrar-vars test-name)

    ;;------------------------------
    ;; Valid Unbinds
    ;;------------------------------
    (let ((registrar :debug)
          (layout    :testing)
          (state     :init))

      (let ((type      :common)
            (unbinds-0 '(:n "s" :layout:common:undefined))
            (unbinds-1 '(:e "u" #'ignore)))

        ;;---
        ;; Unbinds #0: First!
        ;;---
        (should (int<keyboard>:layout:unbind registrar
                                             layout
                                             type
                                             unbinds-0))

        ;; 1) Should have transitioned to init state.
        ;; 2) <no keybinds>
        ;; 3) Should only have the `unbinds-0'.
        (test<keyboard/layout>:assert:registrar-vars
         test-name
         state
         nil
         (test<keyboard/layout>:bind:vars-to-binds type unbinds-0))

        ;;---
        ;; Unbinds #1: Something else.
        ;;---
        ;; `int<keyboard>:layout:unbind' always just overwrites.
        (should (int<keyboard>:layout:unbind registrar
                                             layout
                                             type
                                             unbinds-1))
        ;; 1) Should stay in init state.
        ;; 2) <no keybinds>
        ;; 3) Should now have unbinds 1 instead.
        (test<keyboard/layout>:assert:registrar-vars
         test-name
         state
         nil
         (test<keyboard/layout>:bind:vars-to-binds type unbinds-1))))))


;;------------------------------
;; int<keyboard>:layout:bind
;;------------------------------

(ert-deftest test<keyboard>::int<keyboard>:layout:bind ()
  "Test that `int<keyboard>:layout:bind' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:layout:bind"
      ;; Clear out keybinds before test.
      #'test<keyboard/layout>:setup
      #'test<keyboard/layout>:teardown


    ;;===
    ;; Run the test.
    ;;===
    ;; They should all be nil right now.
    (test<keyboard/layout>:assert:registrar-vars test-name)

    ;;------------------------------
    ;; Valid Binds
    ;;------------------------------
    (let ((registrar :debug)
          (layout    :testing)
          (state     :init))

      (let ((type      :common)
            (binds-0 '(:n "s" :layout:common:undefined))
            (binds-1 '(:e "u" #'ignore)))

        ;;---
        ;; Binds #0: First!
        ;;---
        (should (int<keyboard>:layout:bind registrar
                                           layout
                                           type
                                           binds-0))

        ;; 1) Should have transitioned to init state.
        ;; 2) Should only have the `binds-0'.
        ;; 3) <no unbinds>
        (test<keyboard/layout>:assert:registrar-vars
         test-name
         state
         (test<keyboard/layout>:bind:vars-to-binds type binds-0)
         nil)

        ;;---
        ;; Binds #1: Something else.
        ;;---
        ;; `int<keyboard>:layout:bind' always just overwrites.
        (should (int<keyboard>:layout:bind registrar
                                           layout
                                           type
                                           binds-1))
        ;; 1) Should stay in init state.
        ;; 2) Should now have binds 1 instead.
        ;; 3) <no unbinds>
        (test<keyboard/layout>:assert:registrar-vars
         test-name
         state
         (test<keyboard/layout>:bind:vars-to-binds type binds-1)
         nil)))))
