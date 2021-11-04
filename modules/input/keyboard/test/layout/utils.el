;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/layout/utils.el

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
(load! "../../layout/utils.el")


;;------------------------------------------------------------------------------
;; Set-Up / Tear-Down
;;------------------------------------------------------------------------------

(defun test<keyboard/layout/utils>:setup (_)
  "Set-up for 'layout/utils.el' tests."
  ;; Start off in a fresh state.
  (int<keyboard>:registrar:set test<keyboard/layout>:registrar
                               :state
                               nil)
  (test<keyboard/layout>:setup test-name))


(defun test<keyboard/layout/utils>:teardown (test-name)
  "Tear-down for 'layout/utils.el' tests."
  (test<keyboard/layout>:teardown test-name))


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Unbind Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:layout/types:normalize->func
;;------------------------------

(ert-deftest test<keyboard>::int<keyboard>:layout/types:normalize->func ()
  "Test that `int<keyboard>:layout/types:normalize->func' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:layout/types:normalize->func"
      ;; Clear out keybinds before test.
      #'test<keyboard/layout>:setup
      #'test<keyboard/layout>:teardown


    ;;===
    ;; Run the test.
    ;;===
    ;; They should all be nil right now.
    (test<keyboard/layout>:assert:registrar-vars test-name)

    ;;------------------------------
    ;; Create some keyword->func pairs...
    ;;------------------------------
    (let ((int
           ))


    )))


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


;;------------------------------
;; int<keyboard>:layout:config
;;------------------------------

(ert-deftest test<keyboard>::int<keyboard>:layout:config ()
  "Test that `int<keyboard>:layout:config' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:layout:config"
      ;; Clear out keybinds before test.
      #'test<keyboard/layout>:setup
      #'test<keyboard/layout>:teardown

    ;;===
    ;; Run the test.
    ;;===
    ;; They should all be nil right now.
    (test<keyboard/layout>:assert:registrar-vars test-name)

    ;;------------------------------
    ;; Create some valid binds.
    ;;------------------------------
    (let ((registrar :debug)
          (layout    :testing)
          (type      :evil)
          (binds '(:nvm "C-c <C-F15>" #'test<keyboard/layout>:bind:count/00)))

      (let ((state/before nil)
            (state/after  :init))
        (test<keyboard/layout>:assert:registrar-vars
         test-name
         state/before
         nil
         nil)

        (should (int<keyboard>:layout:bind registrar
                                           layout
                                           type
                                           binds))

        (test<keyboard/layout>:assert:registrar-vars
         test-name
         state/after
         (test<keyboard/layout>:bind:vars-to-binds type binds)
         nil))

      ;;------------------------------
      ;; Config the binds.
      ;;------------------------------
      (let ((state/before :init)
            (state/after  :config)
            (bind/unbind  :full))
        ;; Config doesn't really do anything except the state change...
        (should (int<keyboard>:layout:config registrar
                                             bind/unbind
                                             layout))

        (test<keyboard/layout>:assert:registrar-vars
         test-name
         state/after
         (test<keyboard/layout>:bind:vars-to-binds type binds)
         nil)))))


;;------------------------------
;; int<keyboard>:layout:activate
;;   - Test with only unbinds.
;;------------------------------

(ert-deftest test<keyboard>::int<keyboard>:layout:activate::only-unbinds ()
  "Test that `int<keyboard>:layout:activate' will apply some unbinds (no keybinds)."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:layout:activate::only-unbinds"
      ;; Clear out keybinds before test.
      #'test<keyboard/layout>:setup
      #'test<keyboard/layout>:teardown

    ;;===
    ;; Run the test.
    ;;===
    ;; They should all be nil right now.
    (test<keyboard/layout>:assert:registrar-vars test-name)

    ;;------------------------------
    ;; Create some valid binds.
    ;;------------------------------
    (-let* ((registrar   :debug)
            (bind/unbind :full)
            (layout      :testing)
            (types       '(:evil))
            (unbinds     '(:nvm "C-c <C-F15>" :layout:common:undefined
                           :e   "C-c <C-F16>" :layout:common:undefined
                           :i   "C-c <C-F17>" :layout:common:undefined))
            (binds       nil)
            ;; This creates the keybinds & unbinds.
            ((unbound . bound) (test<keyboard/layout>:bind:make test-name :init :config binds unbinds))
            activated)

      (should unbound)
      (should-not bound)

      ;;------------------------------
      ;; Activate the binds.
      ;;------------------------------
      ;; Don't actually bind these - just want to check the return value.
      (setq activated
            (int<keyboard>:layout:activate registrar
                                           bind/unbind
                                           types
                                           :no-eval))
      (should activated)

      (test<keyboard/layout>:assert:registrar-vars test-name
                                                   :active
                                                   bound
                                                   unbound))))


;;------------------------------
;; int<keyboard>:layout:activate
;;   - Test with only binds.
;;------------------------------

(ert-deftest test<keyboard>::int<keyboard>:layout:activate::only-binds ()
  "Test that `int<keyboard>:layout:activate' will apply some keybinds (no unbinds)."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:layout:activate::only-binds"
      ;; Clear out keybinds before test.
      #'test<keyboard/layout>:setup
      #'test<keyboard/layout>:teardown

    ;;===
    ;; Run the test.
    ;;===
    ;; They should all be nil right now.
    (test<keyboard/layout>:assert:registrar-vars test-name)

    ;;------------------------------
    ;; Create some valid binds.
    ;;------------------------------
    (-let* ((registrar   :debug)
            (bind/unbind :full)
            (layout      :testing)
            (types       '(:evil))
            (binds       '(:nvm "C-c <C-F15>" #'test<keyboard/layout>:bind:count/00
                           :e   "C-c <C-F16>" #'test<keyboard/layout>:bind:count/01
                           :i   "C-c <C-F17>" #'test<keyboard/layout>:bind:count/02))
            (unbinds     nil)
            ;; This creates the keybinds & unbinds.
            ((unbound . bound) (test<keyboard/layout>:bind:make test-name :init :config binds unbinds))
            activated)

      (should-not unbound)
      (should bound)

      ;;------------------------------
      ;; Activate the binds.
      ;;------------------------------
      ;; Don't actually bind these - just want to check the return value.
      (setq activated
            (int<keyboard>:layout:activate registrar
                                           bind/unbind
                                           types
                                           :no-eval))
      ;; Is this wrapped one too many times?
      ;; Currently is:
      ;;   ((progn
      ;;      (general-define-key :states 'insert "C-c <C-F17>" #'test<keyboard/layout>:bind:count/02)
      ;;      (general-define-key :states 'emacs "C-c <C-F16>" #'test<keyboard/layout>:bind:count/01)
      ;;      (general-define-key :states 'motion "C-c <C-F15>" #'test<keyboard/layout>:bind:count/00)
      ;;      (general-define-key :states 'visual "C-c <C-F15>" #'test<keyboard/layout>:bind:count/00)
      ;;      (general-define-key :states 'normal "C-c <C-F15>" #'test<keyboard/layout>:bind:count/00))
      ;;    nil)
      ;; Should it be?:
      ;;   (progn
      ;;     (general-define-key :states 'insert "C-c <C-F17>" #'test<keyboard/layout>:bind:count/02)
      ;;     (general-define-key :states 'emacs "C-c <C-F16>" #'test<keyboard/layout>:bind:count/01)
      ;;     (general-define-key :states 'motion "C-c <C-F15>" #'test<keyboard/layout>:bind:count/00)
      ;;     (general-define-key :states 'visual "C-c <C-F15>" #'test<keyboard/layout>:bind:count/00)
      ;;     (general-define-key :states 'normal "C-c <C-F15>" #'test<keyboard/layout>:bind:count/00))
      ;; TODO [2021-11-03]: That may be our bug, but... that's a bugfix for the 'test/layout/layout.el' tests.
      ;;
      ;; Anyways. We should get... something. A non-nil. What, exactly, is for other tests.
      (should activated)

      (test<keyboard/layout>:assert:registrar-vars test-name
                                                   :active
                                                   bound
                                                   unbound))))
