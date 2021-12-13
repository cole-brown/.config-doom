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
(load! "../vars.el")
(load! "../load.el")
(load! "../alist.el")
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
;; int<keyboard>:registration:state:valid?
;;------------------------------

(ert-deftest test<keyboard/registrars>::int<keyboard>:registration:state:valid? ()
  "Test that `int<keyboard>:registration:state:valid?' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/registrars>::int<keyboard>:registration:state:valid?"
      nil
      nil

    ;;---
    ;; Good values:
    ;;---
    (should (equal '(nil)
                   (int<keyboard>:registration:state:valid? nil)))
    (should (equal '(nil :apply)
                   (int<keyboard>:registration:state:valid? :init)))
    (should (equal '(:init)
                   (int<keyboard>:registration:state:valid? :config)))
    (should (equal '(:config)
                   (int<keyboard>:registration:state:valid? :active)))
    (should (equal '(nil :init :config)
                   (int<keyboard>:registration:state:valid? :inactive)))
    (should (equal int<keyboard>:registration:states
                   (int<keyboard>:registration:state:valid? :apply)))

    ;;---
    ;; Bad values:
    ;;---
    (should-not (int<keyboard>:registration:state:valid? :invalid))
    (should-not (int<keyboard>:registration:state:valid? 42))
    (should-not (int<keyboard>:registration:state:valid? 'invalid))))


;;------------------------------
;; int<keyboard>:registration:valid/action?
;;------------------------------

(ert-deftest test<keyboard/registrars>::int<keyboard>:registration:valid/action? ()
  "Test that `int<keyboard>:registration:valid/action?' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/registrars>::int<keyboard>:registration:valid/action?"
      nil
      nil

    ;;---
    ;; Good values:
    ;;---
    (should (int<keyboard>:registration:valid/action? :bind))
    (should (int<keyboard>:registration:valid/action? :unbind))
    (should (int<keyboard>:registration:valid/action? :full))

    ;;---
    ;; Bad values:
    ;;---
    (should-not (int<keyboard>:registration:valid/action? :invalid))
    (should-not (int<keyboard>:registration:valid/action? 42))
    (should-not (int<keyboard>:registration:valid/action? 'invalid))))


;;------------------------------
;; int<keyboard>:registration:state/transition:valid?
;;------------------------------

(ert-deftest test<keyboard/registrars>::int<keyboard>:registration:state/transition:valid? ()
  "Test that `int<keyboard>:registration:state/transition:valid?' behaves."

  (let* ((error-count 0)
         (error:get-and-incr (lambda ()
                                "Increment expected error count and return it."
                                (setq error-count (1+ error-count)))))

    (test<keyboard>:fixture
        ;; Test name, setup func, teardown func.
        "test<keyboard/registrars>::int<keyboard>:registration:state/transition:valid?"
        nil
        nil

      ;;------------------------------
      ;; Lexically binding doesn't work since registrars use `symbol-value'.
      ;;------------------------------
      (let ((int<keyboard>:registrar<actual>:state nil)
            (int<keyboard>:registrar<debug>:state  :init))

        ;;------------------------------
        ;; Good transitions:
        ;;------------------------------
        (should (eq nil (int<keyboard>:registrar:get :actual :state)))
        (should (int<keyboard>:registration:state/transition:valid? :actual :init))

        (should (eq :init (int<keyboard>:registrar:get :debug :state)))
        (should (int<keyboard>:registration:state/transition:valid? :debug :config))

        ;;------------------------------
        ;; Bad transitions: error or nil, depending.
        ;;------------------------------

        ;;---
        ;; Invalid `state/to'.
        ;;---
        ;; Default behavior is to raise an error signal, which we are intercepting because testing...
        (test<keyboard>:assert:output :error test-name error-count)
        (int<keyboard>:registration:state/transition:valid? :actual :invalid)
        (test<keyboard>:assert:output :error test-name (funcall error:get-and-incr))
        (int<keyboard>:registration:state/transition:valid? :debug 42)
        (test<keyboard>:assert:output :error test-name (funcall error:get-and-incr))
        (int<keyboard>:registration:state/transition:valid? :debug 'invalid)
        (test<keyboard>:assert:output :error test-name (funcall error:get-and-incr))

        ;; Can change to just "return nil".
        (should-not (int<keyboard>:registration:state/transition:valid? :actual :invalid :no-error))
        ;; Did not add to the number of errors.
        (test<keyboard>:assert:output :error test-name error-count)
        (should-not (int<keyboard>:registration:state/transition:valid? :debug 42 :no-error))
        (test<keyboard>:assert:output :error test-name error-count)
        (should-not (int<keyboard>:registration:state/transition:valid? :debug 'invalid :no-error))
        (test<keyboard>:assert:output :error test-name error-count))

      ;;---
      ;; Invalid `state/current'.
      ;;---
      ;; `:apply' state is best for this since it can be transitioned to from the most states.
      (let ((state/to :apply)
            (int<keyboard>:registrar<actual>:state :invalid)
            (int<keyboard>:registrar<debug>:state  42))
        ;; Default behavior is to raise an error signal, which we are intercepting because testing...
        (test<keyboard>:assert:output :error test-name error-count)
        (int<keyboard>:registration:state/transition:valid? :actual state/to)
        (test<keyboard>:assert:output :error test-name (funcall error:get-and-incr))
        (int<keyboard>:registration:state/transition:valid? :debug state/to)
        (test<keyboard>:assert:output :error test-name (funcall error:get-and-incr))
        (int<keyboard>:registration:state/transition:valid? :debug state/to)
        (test<keyboard>:assert:output :error test-name (funcall error:get-and-incr))

        ;; Can change to just "return nil".
        (should-not (int<keyboard>:registration:state/transition:valid? :actual state/to :no-error))
        ;; Did not add to the number of errors.
        (test<keyboard>:assert:output :error test-name error-count)
        (should-not (int<keyboard>:registration:state/transition:valid? :debug state/to :no-error))
        (test<keyboard>:assert:output :error test-name error-count)
        (should-not (int<keyboard>:registration:state/transition:valid? :debug state/to :no-error))
        (test<keyboard>:assert:output :error test-name error-count))

      ;;---
      ;; Invalid state transition.
      ;;---
      (let ((int<keyboard>:registrar<actual>:state nil)
            (int<keyboard>:registrar<debug>:state  :init))
        ;; Default behavior is to raise an error signal, which we are intercepting because testing...
        (test<keyboard>:assert:output :error test-name error-count)
        (should-not (int<keyboard>:registration:state/transition:valid? :actual :config))
        (test<keyboard>:assert:output :error test-name (funcall error:get-and-incr))
        (should-not (int<keyboard>:registration:state/transition:valid? :debug nil))
        (test<keyboard>:assert:output :error test-name (funcall error:get-and-incr))
        (should-not (int<keyboard>:registration:state/transition:valid? :debug :active))
        (test<keyboard>:assert:output :error test-name (funcall error:get-and-incr))

        ;; Can change to just "return nil".
        (should-not (int<keyboard>:registration:state/transition:valid? :actual :config :no-error))
        ;; Did not add to the number of errors.
        (test<keyboard>:assert:output :error test-name error-count)
        (should-not (int<keyboard>:registration:state/transition:valid? :debug nil :no-error))
        (test<keyboard>:assert:output :error test-name error-count)
        (should-not (int<keyboard>:registration:state/transition:valid? :debug :active :no-error))
        (test<keyboard>:assert:output :error test-name error-count)))))


;;------------------------------
;; int<keyboard>:registration:state/transition:set
;;------------------------------

(ert-deftest test<keyboard/registrars>::int<keyboard>:registration:state/transition:set ()
  "Test that `int<keyboard>:registration:state/transition:set' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/registrars>::int<keyboard>:registration:state/transition:set"
      nil
      nil

    ;;------------------------------
    ;; Lexically bind the state symbols to some initial values.
    ;;------------------------------
    (let ((int<keyboard>:registrar<actual>:state nil)
          (int<keyboard>:registrar<debug>:state  :init))

      ;;---
      ;; Good Transitions:
      ;;---
      (test<keyboard>:should:marker test-name "Good Transitions")

      (should (eq nil (int<keyboard>:registrar:get :actual :state)))
      (should (int<keyboard>:registration:state/transition:set :actual :init))
      (should (eq :init (int<keyboard>:registrar:get :actual :state)))

      (should (eq :init (int<keyboard>:registrar:get :debug :state)))
      (should (int<keyboard>:registration:state/transition:set :debug :config))
      (should (eq :config (int<keyboard>:registrar:get :debug :state)))

      ;;---
      ;; Bad Transitions: error or nil, depending.
      ;;---
      (test<keyboard>:should:marker test-name "Bad Transitions")
      (should-error (int<keyboard>:registration:state/transition:set :actual :invalid))
      (should (eq :init (int<keyboard>:registrar:get :actual :state)))

      (should-error (int<keyboard>:registration:state/transition:set :debug 42))
      (should (eq :config (int<keyboard>:registrar:get :debug :state)))
      (should-error (int<keyboard>:registration:state/transition:set :debug 'invalid))
      (should (eq :config (int<keyboard>:registrar:get :debug :state))))))


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
