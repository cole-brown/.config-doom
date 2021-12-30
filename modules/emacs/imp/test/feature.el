;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; emacs/imp/test/feature.el


;;------------------------------------------------------------------------------
;; Test Requirements
;;------------------------------------------------------------------------------

(load! "base.el")


;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

;;------------------------------
;; `imp:features'.
;;------------------------------
;;

(defvar test<imp/feature>:features:backup nil
  "Backup `imp:features' so we can test it and then restore to its actual values.")


(defvar test<imp/feature>:features:test nil
  "Save `imp:features' after a test so we can check it for debugging if needed.")


;;------------------------------
;; Set-Up / Tear-Down
;;------------------------------

(defun test<imp/feature>:setup (_)
  "Backup `imp:features' and clear it out for 'feature.el' testing."
  (setq test<imp/feature>:features:backup      imp:features
        imp:features                           nil
        test<imp/feature>:features:test-values nil))


(defun test<imp/feature>:teardown (test-name)
  "Restore `imp:features'."
  ;; Save whatever testing did to `test<imp/feature>:features:test-values'
  (setq test<imp/feature>:features:test-values   imp:features
        ;; Restore `imp:features'.
        imp:features test<imp/feature>:features:backup
        test<imp/feature>:features:backup nil))


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠══════════╤══════════════════╧═══════════╧══════════════════╤══════════════╣
;; ╟──────────┤ Because Emacs needs to give Features some love... ├──────────────╢
;; ╚══════════╧═════════════════════════════════════════════════╧══════════════╝


;;------------------------------------------------------------------------------
;; Tests: Imp Feature Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<imp>:feature:normalize:imp->emacs
;;------------------------------

(ert-deftest test<imp/feature>::int<imp>:feature:normalize:imp->emacs ()
  "Test that `int<imp>:feature:normalize:imp->emacs' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/feature>::int<imp>:feature:normalize:imp->emacs"
      #'test<imp/feature>:setup
      #'test<imp/feature>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (should (equal 'imp:test:symbols
                   (int<imp>:feature:normalize:imp->emacs '(:imp test symbols))))

    (should (equal 'imp:provide
                   (int<imp>:feature:normalize:imp->emacs '(:imp provide))))

    (should-error (int<imp>:feature:normalize:imp->emacs '("imp" "strings")))))


;;------------------------------
;; imp:feature:normalize
;;------------------------------

(ert-deftest test<imp/feature>::imp:feature:normalize ()
  "Test that `imp:feature:normalize' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/feature>::imp:feature:normalize"
      #'test<imp/feature>:setup
      #'test<imp/feature>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (should (equal '(:imp test symbols)
                   (imp:feature:normalize :imp 'test 'symbols)))

    (should (equal '(:imp provide)
                   (imp:feature:normalize :imp 'provide)))

    (should (equal '(:imp :strings)
                   (imp:feature:normalize "imp" "strings")))))


;;------------------------------
;; int<imp>:feature:add
;;------------------------------

(ert-deftest test<imp/feature>::int<imp>:feature:add ()
  "Test that `int<imp>:feature:add' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/feature>::int<imp>:feature:add"
      #'test<imp/feature>:setup
      #'test<imp/feature>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (let (features)
      ;; We should have nothing right now.
      (should-not imp:features)
      (should (equal features imp:features))

      ;; Add a feature.
      (setq features '((:imp (test (symbols)))))
      (should (equal features
                     (int<imp>:feature:add '(:imp test symbols))))
      (should (equal features imp:features))

      ;; Another feature.
      (setq features '((:imp (provide) (test (symbols)))))
      (should (equal features
                     (int<imp>:feature:add '(:imp provide))))
      (should (equal features imp:features))

      ;; And another?
      ;; Errors because features should be normalized before calling `int<imp>:feature:add'.
      (should-error (int<imp>:feature:add '("imp" "strings"))))))
