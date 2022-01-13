;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; imp/test/base.el


;;------------------------------------------------------------------------------
;; Base Functionality for Testing
;;------------------------------------------------------------------------------

;; Load whatever should always be loaded for all tests.
(load! "../error")
(load! "../debug")


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Per-Test-Suite
;;------------------------------

(defvar test<imp>:suite:func/setup nil
  "Set-up function to run for the current testing suite.")


(defvar test<imp>:suite:func/teardown nil
  "Tear-down function to run for the current testing suite.")


(defvar test<imp>:should:marker/counter 0
  "Counter for `test<imp>:should:marker'.")


;;------------------------------
;; `imp:features' & `imp:path:roots'
;;------------------------------

(defvar test<imp>:features:backup nil
  "Backup `imp:features' so we can test it and then restore to its actual values.")


(defvar test<imp>:features:test nil
  "Save `imp:features' after a test so we can check it for debugging if needed.")


(defvar test<imp>:path:roots:backup nil
  "Backup `imp:path:roots' so we can test it and then restore to its actual values.")


(defvar test<imp>:path:roots:test nil
  "Save `imp:path:roots' after a test so we can check it for debugging if needed.")


;;------------------------------
;; "ERT List of Should Forms" buffer help
;;------------------------------

(defun test<imp>:should:marker (test-name &rest args)
  "Put a `should' in the test which will evaluate to some searchable output for
marking where in a test you are.

Search for \"[MARK-\[0-9\]+]:\"."
  ;;---
  ;; Big noticeable banner.
  ;;---
  (let ((fmt:str (concat "\n"
                         "╔═════════════════════════════════════╗\n"
                         "╠══╣            MARK-%02d            ╠══╣\n"
                         "╚═╤═══════════════════════════════════╝\n"))
        formatted)

    ;;---
    ;; Test's name and the `args' to print.
    ;;---
    (if (null args)
        ;; No extra stuff in `fmt:str` when no ARGS.
        (setq fmt:str (concat fmt:str
                              "  └──┤ " test-name "\n"))

      ;; `test-name' and the args.
      (setq fmt:str (concat fmt:str
                            "  │\n"
                            "  ├──┤ " test-name "\n"
                            "  │\n"
                            "  └────┤ "
                            ;; String formatting if just a str, else "whatever" formatting.
                            (cond ((and (= 1 (length args))
                                        (stringp (nth 0 args)))
                                   "%s")
                                  (t
                                   "%S"))
                            "\n")))

    ;;---
    ;; Output
    ;;---

    ;; Eval string first so it's cleaner in the list of asserts.
    (setq formatted (apply #'format fmt:str
                           test<imp>:should:marker/counter
                           args))

    ;; Increment counter for next time.
    (setq test<imp>:should:marker/counter
          (1+ test<imp>:should:marker/counter))

    ;; Assert the string so it ends up in the list of asserts.
    (should formatted)))
;; (test<imp>:should:marker "test name" "marker name")


(defun test<imp>:should:marker:small (&rest args)
  "Put a `should' in the test which will evaluate to some searchable output for
marking where in a test you are.

Search for \"[MARK-\[0-9\]+]:\"."
  ;;---
  ;; Smaller noticeable banner.
  ;;---
  (let ((fmt:str (if args
                     (concat "\n"
                         "───────────\n"
                         "  MARK-%02d\n"
                         "──┬────────\n")
                   (concat "\n"
                           "───────────\n"
                           "  MARK-%02d\n"
                           "───────────\n")))
        formatted)

    ;;---
    ;; `args' to print?
    ;;---
    (when args
      (setq fmt:str (concat fmt:str
                            "  └──┤ "
                            ;; String formatting if just a str, else "whatever" formatting.
                            (cond ((and (= 1 (length args))
                                        (stringp (nth 0 args)))
                                   "%s")
                                  (t
                                   "%S"))
                            "\n")))
    ;;---
    ;; Output
    ;;---

    ;; Eval string first so it's cleaner in the list of asserts.
    (setq formatted (apply #'format fmt:str
                           test<imp>:should:marker/counter
                           args))

    ;; Increment counter for next time.
    (setq test<imp>:should:marker/counter
          (1+ test<imp>:should:marker/counter))

    ;; Assert the string so it ends up in the list of asserts.
    (should formatted)))
;; (test<imp>:should:marker:small "mark name")


;;------------------------------------------------------------------------------
;; Test Helpers
;;------------------------------------------------------------------------------

(defun test<imp>:path/file:this ()
  "Filepath of caller file, depending on if this is being loaded or looked at."
  (if load-in-progress
      load-file-name
    (buffer-file-name)))
;; (test<imp>:path/file:this)


(defun test<imp>:path/dir:this ()
  "Filepath of caller file, depending on if this is being loaded or looked at."
  (file-name-directory (test<imp>:path/file:this)))


;;------------------------------------------------------------------------------
;; Test Fixture (Set-Up / Tear-Down) Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; Per-Test-Suite
;;------------------------------

(defun test<imp>:setup/suite (func/setup func/teardown)
  "Hook in any per-suite set-up/tear-down functions.

FUNC/SETUP and FUNC/TEARDOWN should take args:
  - string: NAME - the test's name

FUNC/SETUP will run as last step in set-up.
FUNC/TEARDOWN will run as first step in tear-down."
  (setq test<imp>:suite:func/setup    func/setup
        test<imp>:suite:func/teardown func/teardown))


;;------------------------------
;; Set-Up
;;------------------------------

(defun test<imp>:setup/vars ()
  "Any setup of consts/vars needed per test."
  ;; Generally, reset vars at start of test so they can be manually inspected after a test is run.
  ;; Except `imp:features' & `imp:path:roots', which needs to be reverted back to valid after every test.
  ;;   - In that case, save the test's values off to `test<imp>:path:roots:test'.


  ;; Backup `imp:features' & `imp:path:roots' and clear it out for any tests that need to use it.
  (setq test<imp>:features:backup   imp:features
        test<imp>:path:roots:backup imp:path:roots
        imp:features                nil
        imp:path:roots              nil
        test<imp>:features:test     nil
        test<imp>:path:roots:test   nil))


(defun test<imp>:setup (name func/setup func/teardown)
  "Run setup for test named NAME.

FUNC/SETUP and FUNC/TEARDOWN will be run during set-up/tear-down if provided."
  ;; Create user from test name if no user provided.
  (test<imp>:setup/suite func/setup
                         func/teardown)

  (test<imp>:setup/vars)


  ;; Always last:
  (when test<imp>:suite:func/setup
    (unwind-protect
        (funcall test<imp>:suite:func/setup name))))


;;------------------------------
;; Tear-Down
;;------------------------------

(defun test<imp>:teardown/vars ()
  "Clear out/clean up vars used during testing so next test or normal Emacs
usage isn't affected."
  ;; Generally, reset vars at start of test so they can be manually inspected after a test is run.
  ;; Except `imp:features' & `imp:path:roots', which needs to be reverted back to valid after every test.
  ;;   - In that case, save the test's values off to `test<imp>:path:roots:test'.

  ;; Restore `imp:path:roots', but save whatever testing did to the `test<imp>:path:roots:test' var.
  (setq test<imp>:features:test     imp:features
        test<imp>:path:roots:test   imp:path:roots
        ;; Restore `imp:features' & `imp:path:roots'.
        imp:features                test<imp>:features:backup
        imp:path:roots              test<imp>:path:roots:backup
        test<imp>:features:backup   nil
        test<imp>:path:roots:backup nil))


(defun test<imp>:teardown (name)
  "Run teardown for tests."
  ;; Always first in actual tear-down:
  (when test<imp>:suite:func/teardown
    (unwind-protect
        (funcall test<imp>:suite:func/teardown name)))

  ;; Generally in reverse order from set-up.
  (test<imp>:teardown/vars))


;;------------------------------
;; Test Fixture Macro
;;------------------------------

(defmacro test<imp>:fixture (name func/setup func/teardown &rest body)
  "Run `test<imp>:setup', then BODY, then ensures `test<imp>:teardown' is
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
           (test<imp>:setup test-name ,func/setup ,func/teardown)

           ,@body)

       ;; Always run tear-down.
       (test<imp>:teardown test-name))))
