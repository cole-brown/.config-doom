;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/utils.el

;;------------------------------------------------------------------------------
;; Test Utils
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(load! "base.el")

;;---
;; Keyboard Files:
;;---
(load! "../utils.el")


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:normalize->string
;;------------------------------

(ert-deftest test<keyboard/utils>::int<keyboard>:normalize->string ()
  "Test that `int<keyboard>:normalize->string' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/utils>::int<keyboard>:normalize->string"
      nil
      nil


    ;;---
    ;; Bad values should error on `symbol-name'?
    ;;---
    ;; Not a string or a symbol -> ERROR
    ;;   (even when (currently) not letting `int<keyboard>:output' raise errors)
    (should-error (int<keyboard>:normalize->string '(invalid)))

    ;;---
    ;; Good values:
    ;;---
    (should (string= "test"
                     (int<keyboard>:normalize->string "+test")))
    (should (string= "test"
                     (int<keyboard>:normalize->string "layout/test")))
    (should (string= "test"
                     (int<keyboard>:normalize->string "layout/+test")))
    (should (string= "test"
                     (int<keyboard>:normalize->string :test)))
    (should (string= "test"
                     (int<keyboard>:normalize->string :layout/test)))
    (should (string= "test"
                     (int<keyboard>:normalize->string :layout/+test)))
    (should (string= "test"
                     (int<keyboard>:normalize->string 'test)))
    (should (string= "test"
                     (int<keyboard>:normalize->string 'layout/test)))
    (should (string= "test"
                     (int<keyboard>:normalize->string 'layout/+test)))))


;;------------------------------
;; int<keyboard>:normalize->keyword
;;------------------------------

(ert-deftest test<keyboard/utils>::int<keyboard>:normalize->keyword ()
  "Test that `int<keyboard>:normalize->keyword' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/utils>::int<keyboard>:normalize->keyword"
      nil
      nil

    ;;---
    ;; Bad values should error on `symbol-name'?
    ;;---
    ;; Not a string or a symbol -> ERROR
    ;;   (even when (currently) not letting `int<keyboard>:output' raise errors)
    (should-error (int<keyboard>:normalize->keyword '(invalid)))

    ;;---
    ;; Good values:
    ;;---
    (should (eq :test
                (int<keyboard>:normalize->keyword "+test")))
    (should (eq :test
                (int<keyboard>:normalize->keyword "layout/test")))
    (should (eq :test
                (int<keyboard>:normalize->keyword "layout/+test")))
    (should (eq :test
                (int<keyboard>:normalize->keyword :test)))
    (should (eq :test
                (int<keyboard>:normalize->keyword :layout/test)))
    (should (eq :test
                (int<keyboard>:normalize->keyword :layout/+test)))
    (should (eq :test
                (int<keyboard>:normalize->keyword 'test)))
    (should (eq :test
                (int<keyboard>:normalize->keyword 'layout/test)))
    (should (eq :test
                (int<keyboard>:normalize->keyword 'layout/+test)))))


;;------------------------------
;; int<keyboard>:states->keyword
;;------------------------------

(ert-deftest test<keyboard/utils>::int<keyboard>:states->keyword ()
  "Test that `int<keyboard>:states->keyword' behaves."

  (test<keyboard>:fixture
      ;; Test name, setup func, teardown func.
      "test<keyboard/utils>::int<keyboard>:states->keyword"
      nil
      nil

    ;;---
    ;; Bad values should error on `symbol-name'?
    ;;---
    ;; Not in the `doom-evil-state-alist':
    (should-error (int<keyboard>:states->keyword '(invalid)))

    ;; Not a list
    (should-error (int<keyboard>:states->keyword :invalid))

    ;;---
    ;; Good values:
    ;;---
    ;; `doom-evil-state-alist':
    ;;   '((?n . normal)
    ;;     (?v . visual)
    ;;     (?i . insert)
    ;;     (?e . emacs)
    ;;     (?o . operator)
    ;;     (?m . motion)
    ;;     (?r . replace)
    ;;     (?g . global))

    (should (eq :n
                (int<keyboard>:states->keyword '(normal))))
    (should (eq :v
                (int<keyboard>:states->keyword '(visual))))
    (should (eq :i
                (int<keyboard>:states->keyword '(insert))))
    (should (eq :eomrg
                (int<keyboard>:states->keyword '(emacs operator motion replace global))))
    (should (eq :nvi
                (int<keyboard>:states->keyword '(normal visual insert))))))
