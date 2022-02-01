;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/vars.el

;;------------------------------------------------------------------------------
;; Test Output Helpers
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(imp:test:load :filename "base.el")

;;---
;; Keyboard Files:
;;---
(imp:test:load :feature:post '(:input keyboard alist)
               :filename      "../alist.el")
(imp:test:load :feature:post '(:input keyboard vars)
               :filename      "../vars.el")


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:layout:type/valid?
;;------------------------------

(ert-deftest test<keyboard/output>::int<keyboard>:layout:type/valid? ()
  "Test that `int<keyboard>:layout:type/valid?' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/output>::int<keyboard>:layout:type/valid?"
      nil
      nil

    ;;---
    ;; Good values:
    ;;---
    (should (equal '(:common . "common")
                   (int<keyboard>:layout:type/valid? :common)))
    (should (equal '(:emacs . "emacs")
                   (int<keyboard>:layout:type/valid? :emacs)))
    (should (equal '(:evil . "evil")
                   (int<keyboard>:layout:type/valid? :evil)))


    ;;---
    ;; Bad values get converted to string and warning message.
    ;;---
    (should-not (int<keyboard>:layout:type/valid? :invalid))
    (should-not (int<keyboard>:layout:type/valid? 42))
    (should-not (int<keyboard>:layout:type/valid? 'invalid))))


;;------------------------------
;; int<keyboard>:layout:type->string
;;------------------------------

(ert-deftest test<keyboard/output>::int<keyboard>:layout:type->string ()
  "Test that `int<keyboard>:layout:type->string' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/output>::int<keyboard>:layout:type->string"
      nil
      nil

    ;;---
    ;; Good values:
    ;;---
    (should (string= "common"
                   (int<keyboard>:layout:type->string :common)))
    (should (string= "emacs"
                   (int<keyboard>:layout:type->string :emacs)))
    (should (string= "evil"
                   (int<keyboard>:layout:type->string :evil)))


    ;;---
    ;; Bad values:
    ;;---
    (should-not (int<keyboard>:layout:type->string :invalid))
    (should-not (int<keyboard>:layout:type->string 42))
    (should-not (int<keyboard>:layout:type->string 'invalid))))


;;------------------------------
;; int<keyboard>:layout:valid?
;;------------------------------

(ert-deftest test<keyboard/output>::int<keyboard>:layout:valid? ()
  "Test that `int<keyboard>:layout:valid?' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/output>::int<keyboard>:layout:valid?"
      nil
      nil

    ;;------------------------------
    ;; Check just the input.
    ;;------------------------------

    ;; Set up desired/active to nil so they won't be compared against.
    (let ((int<keyboard>:layout:desired nil)
          (int<keyboard>:layout:active nil)
          (compare-active? nil))
      (test<keyboard>:should:marker test-name "Just the Input.")

      ;; Both these keywords are valid without any active/desired.
      (should (int<keyboard>:layout:valid? :test compare-active?))
      (should (int<keyboard>:layout:valid? :not-test compare-active?))

      (should-not (int<keyboard>:layout:valid? 'invalid compare-active?)))

    ;;------------------------------
    ;; Check against desired/active.
    ;;------------------------------

    (let ((int<keyboard>:layout:desired :test)
          (int<keyboard>:layout:active nil)
          (compare-active? nil))

      ;;---
      ;; Just desired first.
      ;;---
      (test<keyboard>:should:marker test-name "With 'desired'.")

      ;; Only `:test' is valid now.
      (should (int<keyboard>:layout:valid? :test compare-active?))
      (should-not (int<keyboard>:layout:valid? :not-test compare-active?))

      (should-not (int<keyboard>:layout:valid? 'invalid compare-active?))

      ;;---
      ;; Desired & active.
      ;;---
      (test<keyboard>:should:marker test-name "With 'desired' & 'active'.")

      (setq compare-active? t)
      ;; No active yet, so both fails now.
      (should-not (int<keyboard>:layout:valid? :test compare-active?))
      (should-not (int<keyboard>:layout:valid? :not-test compare-active?))

      (should-not (int<keyboard>:layout:valid? 'invalid compare-active?))

      (setq int<keyboard>:layout:active :test)
       ;; Active set, so `:test' is valid again.
      (should (int<keyboard>:layout:valid? :test compare-active?))
      (should-not (int<keyboard>:layout:valid? :not-test compare-active?))

      (should-not (int<keyboard>:layout:valid? 'invalid compare-active?)))))
