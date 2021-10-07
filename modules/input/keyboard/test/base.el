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

(defvar test<keyboard>:output:warn nil
  "A list of `warn' output messages if we are stealing `warn' calls.")


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


;;------------------------------------------------------------------------------
;; Test Helpers
;;------------------------------------------------------------------------------

(defun test<keyboard>:redirect/warn:advice/override (&rest args)
  "Steals all calls to `warn' and puts them into `test<keyboard>:output:warn' list instead."
  (push (format "%s" args) test<keyboard>:output:warn)
  args)


(defun test<keyboard>:redirect/warn:setup ()
  "Steals all calls to `warn' and puts them into `test<keyboard>:output:warn' list instead."
  (advice-add 'warn :override #'test<keyboard>:redirect/warn:advice/override))
;; (warn "hi 0")
;; (test<keyboard>:redirect/warn:setup)
;; (warn "hi 1")
;; test<keyboard>:output:warn
;; (setq test<keyboard>:output:warn nil)


(defun test<keyboard>:redirect/warn:teardown ()
  "Removes our `warn' override."
  (advice-remove 'warn #'test<keyboard>:redirect/warn:advice/override))
;; (warn "hi 2")
;; (test<keyboard>:redirect/warn:teardown)
;; (warn "hi 3")
;; test<keyboard>:output:warn
;; (setq test<keyboard>:output:warn nil)


(defun test<keyboard>:assert:warn (should-warn)
  "Assert that warnings were/were not issued during the test.

SHOULD-WARN can be:
  - a number
    +  Number of warnings must match this.
  - a list of strings
    + Number of warnings must match list length and each warning must match a string.
  - truthy (other non-nil value)
    + Must be some warnings.
  - falsy (nil)
    + Must be no warnings."
  (cond ((numberp should-warn)
         (should (= should-warn
                    (length test<keyboard>:output:warn))))
        ((listp should-warn)
         (should (= (length should-warn)
                    (length test<keyboard>:output:warn)))
         (dotimes (i (length should-warn))
           (string= (nth i should-warn)
                    (nth i test<keyboard>:output:warn))))
        ((not should-warn)
         (should-not test<keyboard>:output:warn))
        (t
         (should test<keyboard>:output:warn))))
;; (test<keyboard>:assert:warn nil)


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
  (setq test<keyboard>:output:warn nil))


(defun test<keyboard>:setup (name func/setup func/teardown)
  "Run setup for test named NAME.

FUNC/SETUP and FUNC/TEARDOWN will be run during set-up/tear-down if provided."
  (test<keyboard>:setup/vars)

  (test<keyboard>:advice/replace:warn)
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
  (setq test<keyboard>:output:warn nil))


(defun test<keyboard>:teardown (name)
  "Run teardown for tests."
  ;; Always first:
  (when test<keyboard>:suite:func/teardown
    (unwind-protect
        (funcall test<keyboard>:suite:func/teardown name)))

  ;; Generally in reverse order from set-up.
  (test<keyboard>:advice/replace:warn)
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
  ;; `unwind-protect' lets us run teardown even if errors, etc.
  `(let ((test-name ,name))
     (unwind-protect
         (progn
           (test<keyboard>:setup test-name ,func/setup ,func/teardown)

           ,@body)
       (when test<keyboard>:with:fixture/teardown-fn
         (test<keyboard>:with:fixture/teardown-fn test-name))
       (test<keyboard>:teardown))))
