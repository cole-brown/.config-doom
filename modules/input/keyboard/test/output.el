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
;; Tests: Functions
;;------------------------------------------------------------------------------

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


;;------------------------------
;; int<keyboard>:output:normalize/key
;;------------------------------

(ert-deftest test<keyboard/output>::int<keyboard>:output:normalize/key ()
  "Test that `int<keyboard>:output:normalize/key' behaves."

  (test<keyboard>:fixture
      ;; Test name, teardown func.
      "test<keyboard/output>:simple/stupid"
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

;; TODO: from here
(ert-deftest test<keyboard/output>::int<keyboard>:output:format ()
  "Test that `int<keyboard>:output:format' behaves."

  (test<keyboard>:fixture
      ;; Test name, teardown func.
      "test<keyboard/output>:simple/stupid"
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
      ;; Test name, teardown func.
      "test<keyboard/output>:simple/stupid"
      nil

    ;; Run the test.
    ;; TODO
    (should t)))
