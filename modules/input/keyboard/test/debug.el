;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/debug.el

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
(load! "../output.el")
(load! "../debug.el")


;;------------------------------------------------------------------------------
;; Test Helpers: Debug
;;------------------------------------------------------------------------------

;;---
;; NOTE: In general, tests should not mess with debugging vars because you could
;; be debugging and want them that way.
;;
;; 'base.el' has `test<keyboard>:debug:setup' and
;; `test<keyboard>:debug:teardown' specifically to make not of this fact (they
;; are empty stubs as of [2021-10-13]).
;;
;; So we have these for the tests where we /do/ want to mess up the debugging data.
;;---

(defvar test<keyboard/debug>:cache:debugging nil
  "Cache of the value of `int<keyboard>:debugging' so it can be restored
after a test.")


(defvar test<keyboard/debug>:cache:debug:tags nil
  "Cache of the value of `int<keyboard>:debug:tags' so it can be restored
after a test.")


(defvar test<keyboard/debug>:called? nil
  "Store whether the `test<keyboard/debug>:call' has been called.")


(defun test<keyboard/debug>:disable-debugging ()
  "Turn off debugging, delete tags."
  (setq int<keyboard>:debugging  nil
        int<keyboard>:debug:tags nil))

(defun test<keyboard/debug>:setup (_)
  "Placeholder for reminder not to mess with debugging."
  ;; Save the debugging vars off to our caches.
  (setq test<keyboard/debug>:cache:debugging  int<keyboard>:debugging
        test<keyboard/debug>:cache:debug:tags int<keyboard>:debug:tags)

  ;; And turn off debugging.
 (test<keyboard/debug>:disable-debugging))


(defun test<keyboard/debug>:teardown (_)
  "Placeholder for reminder not to mess with debugging."
  ;; Restore the debugging vars from our caches.
  (setq int<keyboard>:debugging  test<keyboard/debug>:cache:debugging
        int<keyboard>:debug:tags test<keyboard/debug>:cache:debug:tags)
  (setq test<keyboard/debug>:cache:debugging  nil
        test<keyboard/debug>:cache:debug:tags nil)

  ;; Reset tag filters.
  (setq int<keyboard>:debug:tags nil)

  ;; Reset our testing vars.
  (setq test<keyboard/debug>:called? nil))


(defun test<keyboard/debug>:call ()
  "A function to call - if it was called, `test<keyboard/debug>:called?' will be non-nil."
  ;; Set to 1 or increment by 1.
  (setq test<keyboard/debug>:called? (1+ (or test<keyboard/debug>:called? 0))))


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Debug Evaluations
;;------------------------------------------------------------------------------

(ert-deftest test<keyboard/debug>::debug-evals ()
  "Test that the debug macros do not evaluate inputs unless debugging
(w/ correct tags)."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/debug>::debug-evals"
      #'test<keyboard/debug>:setup
      #'test<keyboard/debug>:teardown

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Not debugging -> args not evaluated.
    ;;------------------------------
    ;; First gotta make sure we are not debugging.
    (should-not int<keyboard>:debugging)
    (should-not int<keyboard>:debug:tags)

    ;; And `test<keyboard/debug>:call' hasn't been called yet.
    (should-not test<keyboard/debug>:called?)

    (let ((called?/expected nil)
          ;; Cast a wide net; use ALL THE THINGS!!!
          (debug:tags/checking int<keyboard>:debug:tags/common)
          (debug:tags/using '(:testing)))

      ;;---
      ;; Debug disabled, so expectd this to not eval.
      ;;---
      (int<keyboard>:debug test-name
          debug:tags/using
        "#00: Hello there!"
        (test<keyboard/debug>:call))
      (should-not test<keyboard/debug>:called?)

      ;;---
      ;; Enable debug and now it should be called.
      ;;---
      (setq int<keyboard>:debugging t)
      (setq called?/expected 1)
      (int<keyboard>:debug test-name
          debug:tags/using
        "#01: Hello there!"
        (test<keyboard/debug>:call))
      (should (= called?/expected
                 test<keyboard/debug>:called?))

      ;;---
      ;; Turn on our tags - it should /not/ be evaluted as the `:testing' tag isn't in the list.
      ;;---
      (setq int<keyboard>:debug:tags debug:tags/checking
            int<keyboard>:debugging t)
      (should-not (seq-intersection debug:tags/using int<keyboard>:debug:tags))
      (should-not (int<keyboard>:debugging? debug:tags/using))

      ;; Should not be called, so same expected as before.
      ;; (setq called?/expected 1)
      (int<keyboard>:debug test-name
          debug:tags/using
        "#02: Hello there!"
        (test<keyboard/debug>:call))
      (should (= called?/expected
                 test<keyboard/debug>:called?))

      ;;---
      ;; Add `:testing' tag to list and it should be called again.
      ;;---
      (setq int<keyboard>:debug:tags (seq-concatenate 'list debug:tags/checking debug:tags/using)
            int<keyboard>:debugging t)
      (should (seq-intersection debug:tags/using int<keyboard>:debug:tags))
      (should (int<keyboard>:debugging? debug:tags/using))

      ;; Should be called, so expected+1.
      (setq called?/expected (1+ called?/expected))
      (int<keyboard>:debug test-name
          debug:tags/using
        "#03: Hello there!"
        (test<keyboard/debug>:call))
      (should (= called?/expected
                 test<keyboard/debug>:called?)))))


;;------------------------------------------------------------------------------
;; Tests: Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:debugging?
;;------------------------------

(ert-deftest test<keyboard/debug>::int<keyboard>:debugging? ()
  "Test that `int<keyboard>:debugging?' returns the correct answer."

  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/debug>::int<keyboard>:debugging?"
      #'test<keyboard/debug>:setup
      #'test<keyboard/debug>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (let ((debug:tags/using '(:testing)))

      ;;------------------------------
      ;; Not debugging - always no.
      ;;------------------------------
      (should-not int<keyboard>:debugging)
      (should-not int<keyboard>:debug:tags)

      (should-not (int<keyboard>:debugging? debug:tags/using))
      ;; (Debugging without a tag is always an error.)
      (should-error (int<keyboard>:debugging? nil))

      ;; Set the tag filter and still not debugging.
      (setq int<keyboard>:debug:tags debug:tags/using)
      (should (equal int<keyboard>:debug:tags debug:tags/using))

      (should-not (int<keyboard>:debugging? debug:tags/using))
      (should-error (int<keyboard>:debugging? nil))

      ;;------------------------------
      ;; Debugging - depends on tags.
      ;;------------------------------

      ;; Reset tag filter and enable debugging.
      (setq int<keyboard>:debug:tags nil
            int<keyboard>:debugging  t)
      (should int<keyboard>:debugging)
      (should-not int<keyboard>:debug:tags)

      ;; No tag filter set so should always be true now.
      (should (int<keyboard>:debugging? debug:tags/using))
      (should (int<keyboard>:debugging? '(:unused :another-one)))
      (should-error (int<keyboard>:debugging? nil))

      ;; Add a filter and now it depends on input tags.
      (setq int<keyboard>:debug:tags debug:tags/using)
      (should int<keyboard>:debugging)
      (should (equal int<keyboard>:debug:tags debug:tags/using))

      (should (int<keyboard>:debugging? debug:tags/using))
      (should-not (int<keyboard>:debugging? '(:unused :another-one)))
      (should-error (int<keyboard>:debugging? nil))

      ;; Use /all/ the common tags, then check for something that is not in the common tags list.
      (let ((debug:tags/using '(:testing)))
        (setq int<keyboard>:debug:tags int<keyboard>:debug:tags/common
              int<keyboard>:debugging  t)
        (should-not (seq-intersection debug:tags/using int<keyboard>:debug:tags))
        (should-not (int<keyboard>:debugging? debug:tags/using))))))


;;------------------------------
;; int<keyboard>:debug
;;------------------------------

(ert-deftest test<keyboard/debug>::int<keyboard>:debug ()
  "Test that `int<keyboard>:debug' functions correctly w/ debug toggle & tags."

  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/debug>::int<keyboard>:debug"
      #'test<keyboard/debug>:setup
      #'test<keyboard/debug>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (let* ((debug:tags/using '(:should-trigger-debug-message))
           (debug:tags/not-using '(:NO-DEBUG-MESSAGE))
           (debug:tags/assert (lambda (should-be-debugging?)
                                ;; May or may not be expecting the 'using' tag.
                                (if should-be-debugging?
                                    (should (int<keyboard>:debugging? debug:tags/using))
                                  (should-not (int<keyboard>:debugging? debug:tags/using)))
                                ;; Never expect the 'not-using' tag.
                                (should-not (int<keyboard>:debugging? debug:tags/not-using))))
           (debug:messages nil)
           (debug:call/number 0)
           (debug:call/number:message nil)
           (debug:call/number:fmt (lambda (expected?)
                                    (let ((msg (format "#%02d: Hello there."
                                                  debug:call/number)))
                                      (setq debug:call/number:message msg)
                                      (when expected?
                                        (push (list msg) debug:messages))))))

      ;;------------------------------
      ;; Not debugging - no output.
      ;;------------------------------
      (should-not int<keyboard>:debugging)
      (should-not int<keyboard>:debug:tags)
      (should-not test<keyboard/debug>:called?)
      (test<keyboard>:assert:output :debug test-name nil)
      (funcall debug:tags/assert nil)

      ;; We should not get any output right now as we're not debugging.
      (funcall debug:call/number:fmt nil)
      (int<keyboard>:debug test-name
          debug:tags/using
        debug:call/number:message)
      (setq debug:call/number (1+ debug:call/number))

      (should-not debug:messages)
      (test<keyboard>:assert:output :debug test-name debug:messages)

      ;; We should always get an error when calling without any tags.
      (funcall debug:call/number:fmt nil)
      (should-error
       (int<keyboard>:debug test-name
           nil
         debug:call/number:message))
      (setq debug:call/number (1+ debug:call/number))

      (should-not debug:messages)
      (test<keyboard>:assert:output :debug test-name debug:messages)

      ;;------------------------------
      ;; Debugging - depends on tags.
      ;;------------------------------

      ;; Enable debugging without filtering tags.
      (setq int<keyboard>:debug:tags nil
            int<keyboard>:debugging  t)
      (should int<keyboard>:debugging)
      (should-not int<keyboard>:debug:tags)
      (test<keyboard>:assert:output :debug test-name nil)
      ;; Can't check this yet - no tags filter so everything is a 'yes'.
      ;; (funcall debug:tags/assert nil)

      ;; No tag filter set so should always log the debug message.
      (funcall debug:call/number:fmt :expected)
      (int<keyboard>:debug test-name
           debug:tags/using
        debug:call/number:message)
      (setq debug:call/number (1+ debug:call/number))
      (should debug:messages)
      (should (listp debug:messages))
      (should (= 1 (length debug:messages)))
      (test<keyboard>:assert:output :debug test-name debug:messages)

      ;; Add a filter and now it depends on input tags.
      (setq int<keyboard>:debug:tags debug:tags/using)
      (should int<keyboard>:debugging)
      (should (equal int<keyboard>:debug:tags debug:tags/using))
      (funcall debug:tags/assert :debugging-enabled)

      ;; Use a debug tag not in our filter - no debug message.
      (funcall debug:call/number:fmt nil)
      (int<keyboard>:debug test-name
          debug:tags/not-using
        debug:call/number:message)
      (setq debug:call/number (1+ debug:call/number))
      ;; Same as before - no additional message output.
      (should debug:messages)
      (should (listp debug:messages))
      (should (= 1 (length debug:messages)))
      (test<keyboard>:assert:output :debug test-name debug:messages)

      ;; Use our input tag - no debug message.
      (funcall debug:call/number:fmt :expected)
      (int<keyboard>:debug test-name
           debug:tags/using
        debug:call/number:message)
      (setq debug:call/number (1+ debug:call/number))
      ;; Same as before - no additional message output.
      (should debug:messages)
      (should (listp debug:messages))
      (should (= 2 (length debug:messages)))
      (test<keyboard>:assert:output :debug test-name debug:messages))))
