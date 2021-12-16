;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; alist/test/base.el


;;------------------------------------------------------------------------------
;; Base Functionality for Testing
;;------------------------------------------------------------------------------

;; No always-load files.


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Per-Test-Suite
;;------------------------------

(defvar test<alist>:suite:func/setup nil
  "Set-up function to run for the current testing suite.")


(defvar test<alist>:suite:func/teardown nil
  "Tear-down function to run for the current testing suite.")


(defvar test<alist>:should:marker/counter 0
  "Counter for `test<alist>:should:marker'.")


;;------------------------------
;; "ERT List of Should Forms" buffer help
;;------------------------------

(defun test<alist>:should:marker (test-name &rest args)
  "Put a `should' in the test which will evaluate to some searchable output for
marking where in a test you are.

Search for \"[MARK-\[0-9\]+]:\"."
  ;;---
  ;; Big noticeable banner.
  ;;---
  (let ((fmt/str (concat "\n"
                         "╔═════════════════════════════════════╗\n"
                         "╠══╣            MARK-%02d            ╠══╣\n"
                         "╚═╤═══════════════════════════════════╝\n"))
        formatted)

    ;;---
    ;; Test's name and the `args' to print.
    ;;---
    (if (null args)
        ;; No extra stuff in `fmt/str` when no ARGS.
        (setq fmt/str (concat "  └──┤ " test-name "\n"))

      ;; `test-name' and the args.
      (setq fmt/str (concat fmt/str
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
    (setq formatted (apply #'format fmt/str
                           test<alist>:should:marker/counter
                           args))

    ;; Increment counter for next time.
    (setq test<alist>:should:marker/counter
          (1+ test<alist>:should:marker/counter))

    ;; Assert the string so it ends up in the list of asserts.
    (should formatted)))


;;------------------------------------------------------------------------------
;; Test Fixture (Set-Up / Tear-Down) Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; Per-Test-Suite
;;------------------------------

(defun test<alist>:setup/suite (func/setup func/teardown)
  "Hook in any per-suite set-up/tear-down functions.

FUNC/SETUP and FUNC/TEARDOWN should take args:
  - string: NAME - the test's name

FUNC/SETUP will run as last step in set-up.
FUNC/TEARDOWN will run as first step in tear-down."
  (setq test<alist>:suite:func/setup    func/setup
        test<alist>:suite:func/teardown func/teardown))


;;------------------------------
;; Set-Up
;;------------------------------

(defun test<alist>:setup/vars ()
  "Any setup of consts/vars needed per test."
  )


(defun test<alist>:setup (name func/setup func/teardown)
  "Run setup for test named NAME.

FUNC/SETUP and FUNC/TEARDOWN will be run during set-up/tear-down if provided."
  (test<alist>:setup/suite func/setup
                           func/teardown)

  (test<alist>:setup/vars)

  ;; Always last:
  (when test<alist>:suite:func/setup
    (unwind-protect
        (funcall test<alist>:suite:func/setup name))))


;;------------------------------
;; Tear-Down
;;------------------------------

(defun test<alist>:teardown/vars ()
  "Clear out/clean up vars used during testing so next test or normal Emacs
usage isn't affected."
  )


(defun test<alist>:teardown (name)
  "Run teardown for tests."
  ;; Always first in actual tear-down:
  (when test<alist>:suite:func/teardown
    (unwind-protect
        (funcall test<alist>:suite:func/teardown name)))

  ;; Generally in reverse order from set-up.
  (test<alist>:teardown/vars))


;;------------------------------
;; Test Fixture Macro
;;------------------------------

(defmacro test<alist>:fixture (name func/setup func/teardown &rest body)
  "Run `test<alist>:setup', then BODY, then ensures `test<alist>:teardown' is
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
           (test<alist>:setup test-name ,func/setup ,func/teardown)

           ,@body)

       ;; Always run tear-down.
       (test<alist>:teardown test-name))))
