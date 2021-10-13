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
        (int<keyboard>:output (car data)
                              test-name
                              (cdr data))
        (test<keyboard>:assert:output (car data)
                                      test-name
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
      (test<keyboard>:assert:output :warn test-name 1))))


;;------------------------------
;; int<keyboard>:output:vars/reset
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
;; int<keyboard>:output:message
;;------------------------------

(ert-deftest test<keyboard/output>::int<keyboard>:output:message ()
  "Test that `int<keyboard>:output:message' sends output to the correct place based on verbosity."

  ;;------------------------------
  ;; Test Actual Error signals error
  ;;------------------------------
  ;; Non-testing error output should signal an error.
  (should-error (int<keyboard>:output/message :error "hello there" nil))

  ;;------------------------------
  ;; Test w/ Unit-Testing hooks in-place.
  ;;------------------------------
  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/output>::int<keyboard>:output:message"
      nil
      nil

    ;; Each verbosity level should go to its separate list of intercepted messages.
    (let ((msg.error "[ERROR] Hello there.")
          (msg.warn  "[WARN]  Hello there.")
          (msg.debug "[DEBUG] Hello there."))

      ;;------------------------------
      ;; Test Error
      ;;------------------------------
      ;; This should /not/ error this time.
      (should (int<keyboard>:output/message :error msg.error nil))

      ;; Error should have its message.
      (test<keyboard>:assert:output :error test-name msg.error)
      ;; Warn and debug should have nothing so far.
      (test<keyboard>:assert:output :warn  test-name nil)
      (test<keyboard>:assert:output :debug test-name nil)

      ;;------------------------------
      ;; Test Warning
      ;;------------------------------
      (should (int<keyboard>:output/message :warn msg.warn nil))

      ;; Error & Warn should have their messages now.
      (test<keyboard>:assert:output :error test-name msg.error)
      ;; Debug should still have nothing.
      (test<keyboard>:assert:output :warn  test-name msg.warn)
      (test<keyboard>:assert:output :debug test-name nil)

      ;;------------------------------
      ;; Test Debug
      ;;------------------------------
      (should (int<keyboard>:output/message :debug msg.debug nil))

      ;; All three should have their messages.
      (test<keyboard>:assert:output :error test-name msg.error)
      (test<keyboard>:assert:output :warn  test-name msg.warn)
      (test<keyboard>:assert:output :debug test-name msg.debug))))


;;------------------------------
;; int<keyboard>:output:format
;;------------------------------

(ert-deftest test<keyboard/output>::int<keyboard>:output:format ()
  "Test that `int<keyboard>:output:format' creates a formatting message for error/warn/debug outputs."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/output>::int<keyboard>:output:format"
      nil
      nil

    ;;------------------------------
    ;; Test that it applies formatting to args.
    ;;------------------------------
    (let* ((fmt.args '("Hello, " "%S.")) ;; Some args for creating a formatting string.
           (expected.substrs (list "Hello, %S." ;; Expected formatting string still w/ '%S'.
                                   test-name))  ;; Expected caller name string.
           (formatted (apply #'int<keyboard>:output:format :error test-name fmt.args)))
      ;; Should have got back some sort of string.
      (should formatted)
      (should (stringp formatted))

      ;; Should have our message and our test name in it somewhere.
      (dolist (expected expected.substrs)
        (should (string-match-p expected formatted))))

    ;;------------------------------
    ;; Test different prefixes.
    ;;------------------------------
    (should-not (string= (int<keyboard>:output:format :error test-name "Hello, %s.")
                         (int<keyboard>:output:format :debug test-name "Hello, %s.")))))


;;------------------------------
;; int<keyboard>:output
;;------------------------------

;; TODO: from here
(ert-deftest test<keyboard/output>::int<keyboard>:output ()
  "Test that `int<keyboard>:output' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/output>::int<keyboard>:output"
      nil
      nil

    ;;------------------------------
    ;; Test Error Level
    ;;------------------------------
    (int<keyboard>:output :error
                          test-name
                          '("Hello " "%s... there is a minor case of severe erroring.")
                          "there")

    (test<keyboard>:assert:output :error
                                  test-name
                                  ;; Expect one error message with:
                                  ;;   - test-name
                                  ;;   - formatted output message
                                  (list (list test-name "Hello there... there is a minor case of severe erroring.")))

    ;;------------------------------
    ;; Test Warn Level
    ;;------------------------------
    (int<keyboard>:output :warn
                          test-name
                          "Hello %s; %s."
                          "there"
                          "this is your final warning")

    (test<keyboard>:assert:output :warn
                                  test-name
                                  ;; Expect one warn message with:
                                  ;;   - test-name
                                  ;;   - formatted output message
                                  (list (list test-name "Hello there; this is your final warning.")))

    ;;------------------------------
    ;; Test Debug Level
    ;;------------------------------
    (int<keyboard>:output :debug
                          test-name
                          "I'm afraid I'm infested with bugs, %s..."
                          "Dave")

    (test<keyboard>:assert:output :debug
                                  test-name
                                  ;; Expect one debug message with:
                                  ;;   - test-name
                                  ;;   - formatted output message
                                  (list (list test-name "I'm afraid I'm infested with bugs, Dave...")))))
