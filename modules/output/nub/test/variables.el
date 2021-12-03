;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; output/nub/test/variables.el

;;------------------------------------------------------------------------------
;; Test Requirements
;;------------------------------------------------------------------------------

(load! "base.el")


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠══════════════╤══════════════╧═══════════╧═══════════════╤═════════════════╣
;; ╟──────────────┤ Test the vacillating, varying variables. ├─────────────────╢
;; ╚══════════════╧══════════════════════════════════════════╧═════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; test<nub>:fixture - :user/auto
;;------------------------------

(ert-deftest test<nub/utils>::user/auto ()
  "Test that `:user/auto' works as expected."

  ;; Make sure we start out without any user set.
  (setq test<nub>:user nil)
  (should-not test<nub>:user)

  ;; This macro should set the user. `:user/auto' should mean "use `test<nub>:user:make'".
  (test<nub>:fixture
      ;; Test name, nub user, setup func, teardown func.
      "test<nub/utils>::user/auto"
      :user/auto
      nil
      nil

    ;; `:user/auto' is based off of the test's name, so make sure that's set.
    (should test-name)
    (should (string= "test<nub/utils>::user/auto" test-name))

    ;; `test<nub>:fixture' should have set `test<nub>:user'.
    (should test<nub>:user)
    ;; Want `test<nub>:user' to be `eq', not just `equal'.
    (should (eq test<nub>:user
                (test<nub>:user:make test-name)))))


;;------------------------------
;; test<nub>:fixture - Specified user.
;;------------------------------

(ert-deftest test<nub/utils>::user/manual ()
  "Test that a specified user works as expected."

  ;; Make sure we start out without any user set.
  (setq test<nub>:user nil)
  (should-not test<nub>:user)

  ;; This macro should set the user.
  (test<nub>:fixture
      ;; Test name, nub user, setup func, teardown func.
      "test<nub/utils>::user/manual"
      :jeff
      nil
      nil

    ;; `test<nub>:fixture' should have set `test<nub>:user'.
    (should test<nub>:user)
    ;; `:user/auto' is based off of the test's name, so make sure that's set.
    (should test-name)
    ;; And make sure we are /not/ using `:user/auto' this time.
    (should-not (eq test<nub>:user
                    (test<nub>:user:make test-name)))

    ;; We should instead have the user exactly as we set it.
    (should (eq test<nub>:user :jeff))))


;;------------------------------
;; int<nub>:user:exists?
;;------------------------------

(ert-deftest test<nub/utils>::int<nub>:user:exists? ()
  "Test that `int<nub>:user:exists?' behaves."

  (test<nub>:fixture
      ;; Test name, nub user, setup func, teardown func.
      "test<nub/utils>::int<nub>:user:exists?"
      :user/auto
      nil
      nil

    ;; Assert nub users only has our current testing user.
    (test<nub>:assert:users)))


;;------------------------------
;; int<nub>:init:user
;;------------------------------
;; Already tested by this point.
;; Used in test set-up.


;;------------------------------
;; int<nub>:terminate:user
;;------------------------------
;; Already tested by this point.
;; Used in test set-up.


;;------------------------------
;; int<nub>:var:user-at-level
;;------------------------------

(ert-deftest test<nub/utils>::int<nub>:var:user-at-level ()
  "Test that a specified user works as expected."
  (test<nub>:fixture
      ;; Test name, nub user, setup func, teardown func.
      "test<nub/utils>::int<nub>:var:user-at-level"
      :user/auto
      nil
      nil

    ;; Make sure we have a few levels.
    (should nub:output:levels)
    (should (listp nub:output:levels))
    (should (> (length nub:output:levels)
               1))

    ;; Create an alist of users -> alist of levels -> something.
    (let (alist/user
          alist/level)
      ;; Alist of levels -> something.
      (dolist (level nub:output:levels)
        (push (cons level level) alist/level))

      ;; Alist of users -> alist.
      (push (cons test<nub>:user alist/level) alist/user)

      ;;---
      ;; Test the function.
      ;;---
      (dolist (level nub:output:levels)
        (should (eq level
                    (int<nub>:var:user-at-level test<nub>:user
                                                level
                                                alist/user
                                                :does-not-exist)))))))


;;------------------------------
;; int<nub>:var:prefix
;;------------------------------

(ert-deftest test<nub/utils>::int<nub>:var:prefix ()
  "Test that `int<nub>:var:prefix' works correctly."

  (test<nub>:fixture
      ;; Test name, nub user, setup func, teardown func.
      "test<nub/utils>::int<nub>:var:prefix"
      :user/auto
      nil
      nil

    (let (prefix/default
          prefix/user)

      ;;------------------------------
      ;; Should not have an entry for the user.
      ;;------------------------------
      (should-not (alist-get test<nub>:user int<nub>:var:prefix))

      ;;------------------------------
      ;; Should get default when we ask for something.
      ;;------------------------------
      (should (alist-get int<nub>:var:user:fallback int<nub>:var:prefix))

      (should (stringp (int<nub>:var:prefix int<nub>:var:user:fallback :error)))

      (should (stringp (int<nub>:var:prefix test<nub>:user :error)))

      ;; Save before we test creating/using new prefixes for this user.
      (setq prefix/user (int<nub>:var:prefix test<nub>:user :error)
            prefix/default (int<nub>:var:prefix int<nub>:var:user:fallback :error))

      (should (string= prefix/default
                       prefix/user))

      ;;------------------------------
      ;; Test having actual prefixes.
      ;;------------------------------

      ;; Create some prefixes.
      (int<nub>:init:prefix test<nub>:user
                            '((:error . "[TEST: ERROR   ]: ")
                              (:warn  . "[TEST: WARN    ]: ")
                              (:info  . "[TEST: INFO    ]: ")
                              (:debug . "[TEST:    debug]: ")))

      ;; Should still have fallback user's, unchanged.
      (should (stringp (int<nub>:var:prefix int<nub>:var:user:fallback :error)))
      (should (string= prefix/default
                       (int<nub>:var:prefix int<nub>:var:user:fallback :error)))

      ;; Should now have a different prefix for our user.
      (should (stringp (int<nub>:var:prefix test<nub>:user :error)))

      (should-not (string= (int<nub>:var:prefix test<nub>:user :error)
                           (int<nub>:var:prefix int<nub>:var:user:fallback :error)))
      (should-not (string= prefix/user
                           (int<nub>:var:prefix test<nub>:user :error)))
      (should (string= "[TEST: ERROR   ]: "
                       (int<nub>:var:prefix test<nub>:user :error)))

      ;;------------------------------
      ;; Test the other levels too...
      ;;------------------------------
      (should (string="[TEST: WARN    ]: "
                      (int<nub>:var:prefix test<nub>:user :warn)))
      (should (string="[TEST: INFO    ]: "
                      (int<nub>:var:prefix test<nub>:user :info)))
      (should (string="[TEST:    debug]: "
                      (int<nub>:var:prefix test<nub>:user :debug))))))



;; TODO: tests for funcs for:
;;   - int<nub>:var:enabled?
;;   - int<nub>:var:sink
;;   - int<nub>:var:debugging
;;   - int<nub>:var:debug:tags
;;   - int<nub>:var:debug:tags/common
