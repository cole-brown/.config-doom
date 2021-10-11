;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/test.el

;;------------------------------------------------------------------------------
;; Test Keyboard Layouts
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(load! "base.el")

;;---
;; Keyboard Files:
;;---
(load! "../output.el")


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Basics
;;------------------------------------------------------------------------------

;;---
;; NOTE: Test that the output redirection works first, so that we can use that in the rest of the output tests.
;;---

;;------------------------------
;; Output Redirection
;;------------------------------

(ert-deftest test<keyboard/output>::output-redirection ()
  "Test that our output redirection for testing works."

  (test<keyboard>:fixture
      ;; Test name, teardown func.
      "test<keyboard/output>::output-redirection"
      nil
      nil

    ;; Make sure that they at least simply work.
    (let ((test-data '((:error . "error output")
                       (:warn  . "Warn Output")
                       (:debug . "DEBUG OUTPUT"))))
      (dolist (data test-data)
        (int<keyboard>:output test-name
                              (car data)
                              (cdr data))
        (test<keyboard>:assert:output test-name
                                      (car data)
                                      (list (cdr data)))))))


;;------------------------------------------------------------------------------
;; Tests: Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:output:normalize/key
;;------------------------------

(ert-deftest test<keyboard/output>::int<keyboard>:output:normalize/key ()
  "Test that `int<keyboard>:output:normalize/key' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/output>::int<keyboard>:output:normalize/key"
      nil
      nil

    ;;---
    ;; Good values:
    ;;---
    (should (string= "foo"
                     (int<keyboard>:output:normalize/key "foo")))
    (should (string= "<RET>"
                     (int<keyboard>:output:normalize/key '[RET])))

    ;;---
    ;; Bad values get converted to string and warning message.
    ;;---
    (let ((value '(bad . value)))
      (should (string= (format "%S" value)
                       (int<keyboard>:output:normalize/key value)))
      (test<keyboard>:assert:output test-name :warn 1))))


;;------------------------------
;; int<keyboard>:output:format
;;------------------------------

(ert-deftest test<keyboard/output>::int<keyboard>:output:vars/reset ()
  "Test that `int<keyboard>:output:vars/reset' behaves."

  ;;------------------------------
  ;; Pre-Set-Up; vars should be defaults.
  ;;------------------------------
  ;;---
  ;; Make sure they have some default squirreled away in their property.
  ;;---
  (let ((verbose.default (get 'int<keyboard>:output:verbose :default))
        (funcs.default   (get 'int<keyboard>:output:default :default)))

    (should verbose.default)
    (should funcs.default)

    ;;---
    ;; Set-up hasn't run yet, so check that they're their default value.
    ;;---
    (should (equal verbose.default
                   int<keyboard>:output:verbose))
    (should (equal funcs.default
                   int<keyboard>:output:default))


    ;;------------------------------
    ;; Run Testing Set-Up; expect vars to change to testing values.
    ;;------------------------------
    (test<keyboard>:fixture
        ;; Test name, setup func, teardown func.
        "test<keyboard/output>::int<keyboard>:output:vars/reset"
        nil
        nil

      ;;---
      ;; The vars should have been modified by test set-up.
      ;;---
      (should-not (equal verbose.default
                         int<keyboard>:output:verbose))
      ;; We don't modify the default funcs.
      ;; (should-not (equal funcs.default
      ;;                    int<keyboard>:output:default))

      ;; What they are now depends on debugging flag.
      (should (equal (alist-get test<keyboard>:debugging test<keyboard>:redirect/output:verbose)
                     int<keyboard>:output:verbose))
      ;; We don't modify the default funcs.
      ;; (should (equal (alist-get test<keyboard>:debugging test<keyboard>:redirect/output:verbose)
      ;;                int<keyboard>:output:default))
      )


    ;;------------------------------
    ;; Tear-Down ran; vars are reset.
    ;;------------------------------
    (should (equal verbose.default
                   int<keyboard>:output:verbose))
    (should (equal funcs.default
                   int<keyboard>:output:default))))


;;------------------------------
;; int<keyboard>:output:format
;;------------------------------

;; TODO: from here
(ert-deftest test<keyboard/output>::int<keyboard>:output:format ()
  "Test that `int<keyboard>:output:format' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/output>:simple/stupid"
      nil
      nil

    ;; Run the test.
    ;; TODO
    (should t)))


;;------------------------------
;; int<keyboard>:output:message
;;------------------------------

(ert-deftest test<keyboard/output>::int<keyboard>:output:message ()
  "Test that `int<keyboard>:output:message' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/output>:simple/stupid"
      nil
      nil

    ;; Run the test.
    ;; TODO
    (should t)))
