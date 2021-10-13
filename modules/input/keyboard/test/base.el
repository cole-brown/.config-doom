;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/base.el

;;------------------------------------------------------------------------------
;; Base Functionality for Testing
;;------------------------------------------------------------------------------

;; Get all the keyboard files we want to test.
(load "../init.el")


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar test<keyboard>:output:error nil
  "A list of `:error' output messages if we are stealing `:error' verbosity.")


(defvar test<keyboard>:output:warn nil
  "A list of `:warn' output messages if we are stealing `:warn' verbosity.")
;; test<keyboard>:output:warn
;; (length test<keyboard>:output:warn)

(defvar test<keyboard>:output:debug nil
  "A list of `:debug' output messages if we are stealing `:debug' verbosity.
NOTE: Does not include /test/ debug messages - just the normal keyboard
debugging messages.")


;;------------------------------
;; Per-Test-Suite
;;------------------------------

(defvar test<keyboard>:suite:func/setup nil
  "Set-up function to run for the current testing suite.")


(defvar test<keyboard>:suite:func/teardown nil
  "Tear-down function to run for the current testing suite.")


;;------------------------------------------------------------------------------
;; Test Debugging
;;------------------------------------------------------------------------------

(defvar test<keyboard>:debugging nil
  "Debug toggle specifically for test debugging.
Non-nil means debugging is active.

Does not affect `input//kl:debugging' in any way.")


(defun test<keyboard>:debug/toggle (prefix)
  "Toggle debugging for ':input/keyboard' ERT unit testing.

With prefix arg, will also toggle ':input/keyboard' debugging to same on/off
value as tests' debugging toggle."
  (interactive "P")
  (let* ((name/var.test "test<keyboard>:debugging")
         (name/var.code "input//kl:debugging")
         (state/enabled "[ENABLED]")
         (state/disabled "[-------]")
         (fmt/name (concat "%"
                           (number-to-string (max (length name/var.test)
                                                  (length name/var.code)))
                           "s"))
         (fmt/toggle (concat fmt/name "%s%s%s"))
         (also-normal-debug (not (null prefix))))
    ;; Toggle debug flag(s).
    (setq test<keyboard>:debugging (not test<keyboard>:debugging))
    (when also-normal-debug
      (setq input//kl:debugging test<keyboard>:debugging))

    ;; Notify user what state they're in.
    (message fmt/toggle
             name/var.test
             ;; "transitioned"
             " -> "

             ;; State of test's debugging.
             (if test<keyboard>:debugging
                 state/enabled
               state/disabled)

             ;; And the state of the normal debugging?
             (concat "\n"
                     (if also-normal-debug
                         (format fmt/toggle
                                 name/var.code
                                 ;; "transitioned"
                                 " -> "
                                 ;; State of normal debugging.
                                 (if input//kl:debugging
                                     state/enabled
                                   state/disabled)
                                 ;; Normal debugging tags.
                                 (if input//kl:debugging
                                     (if (not input//kl:debug/tags)
                                         " (all debug output)"
                                       (format " with tags: %S" input//kl:debug/tags))
                                   ""))
                       ;; Else only say if normal debugging is enabled?
                       (format fmt/toggle
                               name/var.code
                               ;; "did not change"
                               " == "
                               (if input//kl:debugging
                                   state/enabled
                                 state/disabled)
                               ""))))))
;; (test<keyboard>:debug/toggle nil)
;; (test<keyboard>:debug/toggle '(4))


(defun test<keyboard>:debug (test-name msg &rest args)
  "debug message"
  (message "[TEST<KEYBOARD>]::%s: %s"
           test-name
           (apply #'format msg args)))
;; (test<keyboard>:debug "test?" "hello %s" "there")


;;------------------------------------------------------------------------------
;; Test Helpers
;;------------------------------------------------------------------------------

(defun test<keyboard>:redirect/output:error (msg &rest args)
  "Steals all calls to `int<keyboard>:output' for `:error' level and puts them
into `test<keyboard>:output:error' list instead."
  (push (apply #'format msg args) test<keyboard>:output:error))


(defun test<keyboard>:redirect/output:warn (msg &rest args)
  "Steals all calls to `int<keyboard>:output' for `:warn' level and puts them
into `test<keyboard>:output:warn' list instead."
  (push (apply #'format msg args) test<keyboard>:output:warn))
;; (test<keyboard>:redirect/output:warn "hello %s" "there")


(defun test<keyboard>:redirect/output:debug (msg &rest args)
  "Steals all calls to `int<keyboard>:output' for `:debug' level and puts them
into `test<keyboard>:output:debug' list instead."
  (push (apply #'format msg args) test<keyboard>:output:debug))


(defconst test<keyboard>:redirect/output:verbose
  '(;; Not in test-debugging - save to our lists and squelch output.
    (nil . ((:error . test<keyboard>:redirect/output:error)
            (:warn  . test<keyboard>:redirect/output:warn)
            (:debug . test<keyboard>:redirect/output:debug)))
    ;; Debugging the tests - save to our lists and also allow to output as usual.
    (t   . ((:error . (test<keyboard>:redirect/output:error t))
            (:warn  . (test<keyboard>:redirect/output:warn  t))
            (:debug . (test<keyboard>:redirect/output:debug t)))))
  "Replace the normal output based on `test<keyboard>:debugging' flag.")


(defun test<keyboard>:redirect/output:setup ()
  "Steals all calls to `int<keyboard>:output' and puts them into `test<keyboard>:output:...' lists instead.

Will also allow the normal output if `test<keyboard>:debugging'."
  (setq int<keyboard>:output:verbose (alist-get test<keyboard>:debugging
                                                test<keyboard>:redirect/output:verbose)))


(defun test<keyboard>:redirect/output:teardown ()
  "Removes our output override."
  (int<keyboard>:output:vars/reset))


(defun test<keyboard>:assert:output (level caller should-be)
  "Assert that LEVEL outputs were/were not issued during the test.

LEVEL should be one of: (:error :warn :debug)

SHOULD-BE can be:
  - a number
    + Number of LEVEL outputs must match this.
    + USING
  - a string
    + Exactly 1 LEVEL output messages.
    + The LEVEL message must match SHOULD-BE.
    + USING
  - a list of lists of strings
    + Each list of strings should be expected substrings in the LEVEL output message.
  - nil/falsy
    + LEVEL should have no output messages."
  (let* ((outputs (pcase level
                    (:error test<keyboard>:output:error)
                    (:warn  test<keyboard>:output:warn)
                    (:debug test<keyboard>:output:debug)
                    (_
                     (error "test<keyboard>:assert:output: Unknown level '%S'. Caller: %S"
                            level caller))))
         (func/assert-list (lambda ()
                             "Assert that the output list exists/is non-nil."
                             (should outputs)
                             (should (listp outputs)))))
    ;; See what level is when debugging.
    (should (format "test<keyboard>:assert:output: level: %S, should-be: %S" level should-be))

    (cond
     ;;---
     ;; Falsy: Nothing should exist.
     ;;---
     ;; NOTE: Must be before listp since `nil' is a list.
     ((not should-be)
      (should-not outputs))

     ;;---
     ;; Number: Exactly that amount of messages in the output list.
     ;;---
     ((numberp should-be)
      ;; Zero is a special case; don't want to assert `outputs' exists.
      (when (> 0 should-be)
        (funcall func/assert-list))
      (should (= should-be
                 (length outputs))))

     ;;---
     ;; String: Should be exactly one message in the output list and it should equal this string.
     ;;---
     ((stringp should-be)
      (funcall func/assert-list)
      (should (= 1
                 (length outputs)))
      (should (string= should-be
                       (nth 0 outputs))))

     ;;---
     ;; List (of lists of strings): match substrings in output list.
     ;;---
     ((listp should-be) ;; Suck all lists into this case, then validate.
      ;;---
      ;; Must be valid list of lists of strings.
      ;;---
      ;; Should have the correct number of substring lists for the messages.
      (should (> (length should-be) 0))
      ;; Each element in list should be a sub-list...
      (should (-all? #'listp should-be))
      ;; ...and each element in each sub-list should be a string.
      (should (-all? (lambda (sublist) (-all? #'stringp sublist))
                     should-be))

      ;; Outputs should be valid, match expected in length.
      (funcall func/assert-list)
      (should (= (length should-be)
                 (length outputs)))

      ;; Should find all the expected substrings in the expected message.
      (dotimes (i (length should-be)) ;; For each message...
        (let ((substrings (nth i should-be))
              (output (nth i outputs)))
          (dotimes (j (length substrings)) ;; For each expected substring...
            (should (string-match-p (nth j substrings) output))))))

     ;;---
     ;; Didn't match anything expected.
     ;;---
     (t
      (error "test<keyboard>:assert:output: Unknown SHOULD-BE: %S" should-be)))))
;; (test<keyboard>:assert:output :warn "test" nil)


;;------------------------------------------------------------------------------
;; Test Fixture (Set-Up / Tear-Down) Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; Per-Test-Suite
;;------------------------------

(defun test<keyboard>:setup/suite (func/setup func/teardown)
  "Hook in any per-suite set-up/tear-down functions.

FUNC/SETUP and FUNC/TEARDOWN should take args:
  - string: NAME - the test's name

FUNC/SETUP will run as last step in set-up.
FUNC/TEARDOWN will run as first step in tear-down."
  (setq test<keyboard>:suite:func/setup    func/setup
        test<keyboard>:suite:func/teardown func/teardown))


;;------------------------------
;; Set-Up
;;------------------------------

(defun test<keyboard>:setup/vars ()
  "Any setup of consts/vars needed per test."
  ;; Reset these at start of test so they can be manually inspected after a test is run.
  (setq test<keyboard>:output:error nil)
  (setq test<keyboard>:output:warn  nil)
  (setq test<keyboard>:output:debug nil))


(defun test<keyboard>:setup (name func/setup func/teardown)
  "Run setup for test named NAME.

FUNC/SETUP and FUNC/TEARDOWN will be run during set-up/tear-down if provided."
  (test<keyboard>:setup/vars)
  (test<keyboard>:redirect/output:setup)

  (test<keyboard>:setup/suite func/setup func/teardown)

  ;; Always last:
  (when test<keyboard>:suite:func/setup
    (unwind-protect
        (funcall test<keyboard>:suite:func/setup name))))


;;------------------------------
;; Tear-Down
;;------------------------------

(defun test<keyboard>:teardown/vars ()
  "Clear out/clean up vars used during testing so next test or normal Emacs
usage isn't affected."

  ;;------------------------------
  ;; `test<keyboard>:output:...'
  ;;------------------------------
  ;; Reset these vars at set-up so they can be inspected after a test is run.
  ;; Do nothing to them here.
  )


(defun test<keyboard>:teardown (name)
  "Run teardown for tests."
  ;; Always first:
  (when test<keyboard>:suite:func/teardown
    (unwind-protect
        (funcall test<keyboard>:suite:func/teardown name)))

  ;; Generally in reverse order from set-up.
  (test<keyboard>:redirect/output:teardown)
  (test<keyboard>:teardown/vars))


;;------------------------------
;; Test Fixture Macro
;;------------------------------

(defmacro test<keyboard>:fixture (name func/setup func/teardown &rest body)
  "Run `test<keyboard>:setup', then BODY, then ensures `test<keyboard>:teardown' is
run no matter what happens in BODY. Binds NAME to symbol `test-name'.

If TEST-TEARDOWN-FN is non-nil, it is /always/ called after the test is run
(even if it errors out/fails/etc). TEST-TEARDOWN-FN should take one parameter:
NAME."
  (declare (indent 3))
  `(let ((test-name ,name))
     ;; `unwind-protect' lets us run teardown even if errors, etc.
     (unwind-protect
         ;; Run test set-up, then the test.
         (progn
           (test<keyboard>:setup test-name ,func/setup ,func/teardown)

           ,@body)
       ;; Always run tear-down.
       (test<keyboard>:teardown test-name))))
