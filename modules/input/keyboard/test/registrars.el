;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/registrar.el

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
(load! "../output.el")
(load! "../debug.el")
;; (load! "../load.el")
;; (load! "../alist.el")
(load! "../registrars.el")


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Registrars Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:registrar:valid?
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:registrar:valid? ()
  "Test that `int<keyboard>:registrar:valid?' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:registrar:valid?"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Check that all our expected registrars' keywords are valid.
    ;;------------------------------
    (should (int<keyboard>:registrar:valid? :actual))
    (should (int<keyboard>:registrar:valid? :debug))

    ;;------------------------------
    ;; Check that other inputs signal errors.
    ;;------------------------------
    (should-error (int<keyboard>:registrar:valid? :invalid))
    (should-error (int<keyboard>:registrar:valid? 'invalid))
    (should-error (int<keyboard>:registrar:valid? 42))))


;;------------------------------
;; int<keyboard>:registrar:symbol
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:registrar:symbol ()
  "Test that `int<keyboard>:registrar:symbol' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:registrar:symbol"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Valid Inputs
    ;;------------------------------
    (should (eq 'int<keyboard>:registrar<actual>:keybinds
                (int<keyboard>:registrar:symbol :actual :keybinds)))
    (should (eq 'int<keyboard>:registrar<actual>:unbinds
                (int<keyboard>:registrar:symbol :actual :unbinds)))
    (should (eq 'int<keyboard>:registrar<actual>:state
                (int<keyboard>:registrar:symbol :actual :state)))

    (should (eq 'int<keyboard>:registrar<debug>:keybinds
                (int<keyboard>:registrar:symbol :debug :keybinds)))
    (should (eq 'int<keyboard>:registrar<debug>:unbinds
                (int<keyboard>:registrar:symbol :debug :unbinds)))
    (should (eq 'int<keyboard>:registrar<debug>:state
                (int<keyboard>:registrar:symbol :debug :state)))

    ;;------------------------------
    ;; Invalid Inputs
    ;;------------------------------
    (should-error (int<keyboard>:registrar:symbol :invalid :keybinds))
    (should-error (int<keyboard>:registrar:symbol :actual  :invalid))
    (should-error (int<keyboard>:registrar:symbol :debug   42))))


;;------------------------------
;; int<keyboard>:registrar:get
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:registrar:get ()
  "Test that `int<keyboard>:registrar:get' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:registrar:get"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Lexically bind all registar symbols to some testing values.
    ;;------------------------------
    (let ((int<keyboard>:registrar<actual>:keybinds :actual/keybinds)
          (int<keyboard>:registrar<actual>:unbinds  :actual/unbinds)
          (int<keyboard>:registrar<actual>:state    :actual/state)
          (int<keyboard>:registrar<debug>:keybinds  :debug/keybinds)
          (int<keyboard>:registrar<debug>:unbinds   :debug/unbinds)
          (int<keyboard>:registrar<debug>:state     :debug/state))

      ;;------------------------------
      ;; Get Expected Values?
      ;;------------------------------
      (should (eq :actual/keybinds
                  (int<keyboard>:registrar:get :actual :keybinds)))
      (should (eq :actual/unbinds
                  (int<keyboard>:registrar:get :actual :unbinds)))
      (should (eq :actual/state
                  (int<keyboard>:registrar:get :actual :state)))

      (should (eq :debug/keybinds
                  (int<keyboard>:registrar:get :debug :keybinds)))
      (should (eq :debug/unbinds
                  (int<keyboard>:registrar:get :debug :unbinds)))
      (should (eq :debug/state
                  (int<keyboard>:registrar:get :debug :state)))

      ;;------------------------------
      ;; Invalid Inputs
      ;;------------------------------
      (should-error (int<keyboard>:registrar:get :invalid :keybinds))
      (should-error (int<keyboard>:registrar:get :actual  :invalid))
      (should-error (int<keyboard>:registrar:get :debug   42)))))


;;------------------------------
;; int<keyboard>:registrar:set
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:registrar:set ()
  "Test that `int<keyboard>:registrar:set' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:registrar:set"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Lexically bind all registar symbols to some initial values.
    ;;------------------------------
    (let ((int<keyboard>:registrar<actual>:keybinds :actual/keybinds:initial)
          (int<keyboard>:registrar<actual>:unbinds  :actual/unbinds:initial)
          (int<keyboard>:registrar<actual>:state    :actual/state:initial)
          (int<keyboard>:registrar<debug>:keybinds  :debug/keybinds:initial)
          (int<keyboard>:registrar<debug>:unbinds   :debug/unbinds:initial)
          (int<keyboard>:registrar<debug>:state     :debug/state:initial))

      ;;------------------------------
      ;; Set, then Get New Values?
      ;;------------------------------
      ;;---
      ;; :actual
      ;;---
      (should (int<keyboard>:registrar:set :actual :keybinds :actual/keybinds:new))
      (should (eq :actual/keybinds:new
                  (int<keyboard>:registrar:get :actual :keybinds)))

      (should (int<keyboard>:registrar:set :actual :unbinds :actual/unbinds:new))
      (should (eq :actual/unbinds:new
                  (int<keyboard>:registrar:get :actual :unbinds)))

      (should (int<keyboard>:registrar:set :actual :state :actual/state:new))
      (should (eq :actual/state:new
                  (int<keyboard>:registrar:get :actual :state)))

      ;;---
      ;; :debug
      ;;---
      (should (int<keyboard>:registrar:set :debug :keybinds :debug/keybinds:new))
      (should (eq :debug/keybinds:new
                  (int<keyboard>:registrar:get :debug :keybinds)))

      (should (int<keyboard>:registrar:set :debug :unbinds :debug/unbinds:new))
      (should (eq :debug/unbinds:new
                  (int<keyboard>:registrar:get :debug :unbinds)))

      (should (int<keyboard>:registrar:set :debug :state :debug/state:new))
      (should (eq :debug/state:new
                  (int<keyboard>:registrar:get :debug :state)))

      ;;------------------------------
      ;; Invalid Inputs
      ;;------------------------------
      (should-error (int<keyboard>:registrar:set :invalid :keybinds))
      (should-error (int<keyboard>:registrar:set :actual  :invalid))
      (should-error (int<keyboard>:registrar:set :debug   42)))))
