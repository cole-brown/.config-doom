;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/_template_.el

;;------------------------------------------------------------------------------------------------------------------------------------------
;; TODO: Template file for Tests
;;------------------------------------------------------------------------------------------------------------------------------------------
;;
;; TODO:
;;   - Find replace: "keyboard/template" with "keyboard/TEST-NAME"
;;   - Search for "TODO" and do one of:
;;     + Implement
;;     + Delete section/function/var/whatever.
;;


;;------------------------------------------------------------------------------
;; Test Keyboard Layouts
;;------------------------------------------------------------------------------

;;---
;; Keyboard Files:
;;---
;; TODO: (load "../error.el")

;;---
;; Testing Files:
;;---
(load "base.el")


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;; TODO:

;;------------------------------------------------------------------------------
;; Test Helpers
;;------------------------------------------------------------------------------

;; TODO:

;;------------------------------------------------------------------------------
;; Test Fixture (Set-Up / Tear-Down) Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; Set-Up
;;------------------------------


(defun test<keyboard/error>:setup/vars ()
  "Any setup of consts/vars needed per test."
  ;; TODO:
  )


(defun test<keyboard/error>:setup (name)
  "Run setup for tests."
  ;; TODO:
  )


;;------------------------------
;; Tear-Down
;;------------------------------

(defun test<keyboard/error>:teardown/vars ()
  "Clear out/clean up vars used during testing so next test or normal Emacs
usage isn't affected."
  ;; TODO:
  )


(defun test<keyboard/error>:teardown ()
  "Run teardown for tests."
  ;; TODO:
  )

;;------------------------------------------------------------------------------
;; Reusable Test Assertions
;;------------------------------------------------------------------------------

(defun test<keyboard/error>:assert:valid-xxx (assert/info-str todo/0 todo/1)
  ""
  ;; TODO:
  )


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: simple
;;------------------------------------------------------------------------------

;;------------------------------
;; TODO: short test description.
;;------------------------------

;; TODO: find/replace "simple/stupid"?
(ert-deftest test<keyboard/error>::simple/stupid ()
  "TODO: simple test docstring"

  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/error>::simple/stupid"
      nil

      ;;===
      ;; Run the test.
      ;;===
      ;; TODO: test functionality here w/:
      ;;   - `should'
      ;;   - `should-not'
      ;;   - `should-error'
      ;;   - "Reusable Tests Assertions" functions
      ))


;;------------------------------------------------------------------------------
;; Tests: functions
;;------------------------------------------------------------------------------

;; TODO: find/replace "int<keyboard:func:name/here" with func name you're testing.
;;------------------------------
;; `int<keyboard:func:name/here'
;;------------------------------

(ert-deftest test<keyboard/error>::int<keyboard>:func:name/here ()
  "TODO: docstring for test `int<keyboard>:func:name/here'."

  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/error>::int<keyboard>:func:name/here"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===
    ;; TODO: test functionality here w/:
    ;;   - `should'
    ;;   - `should-not'
    ;;   - `should-error'
    ;;   - "Reusable Tests Assertions" functions
    ))
